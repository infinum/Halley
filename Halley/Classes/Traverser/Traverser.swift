import Foundation
import Combine
import CombineExt

typealias JSONResult = Result<Any, Error>

class Traverser {

    private let requester: RequesterInterface
    private let requesterQueue: RequesterQueue = .shared
    private let serializationQueue = DispatchQueue(label: "com.hal.serialization.queue", qos: .userInitiated)

    public init(requester: RequesterInterface) {
        self.requester = requester
    }
}

extension Traverser {

    func resource(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default
    ) -> AnyPublisher<JSONResult, Never> {
        return requesterQueue
            .jsonResponse(at: url, requester: requester)
            .subscribe(on: serializationQueue)
            .receive(on: serializationQueue)
            .flatMap { [weak self] result -> AnyPublisher<JSONResult, Never> in
                guard let self = self else { return .failure(HalleyKit.Error.deinited) }
                do {
                    return try self.fetchLinkedResources(for: result, includes: includes, options: options)
                } catch let error {
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Helpers -

private extension Traverser {

    func fetchLinkedResources(
        for result: JSONResult,
        includes: [String],
        options: HalleyKit.Options
    ) throws -> AnyPublisher<JSONResult, Never> {
        let response = try result.asDictionary.get()
        let container = ResourceContainer(response)
        if let type = containsCollectionType(for: container, options: options) {
            return try parseCollectionLinkedResources(for: container, type: type, includes: includes, options: options)
        } else {
            return try fetchSingleResourceLinkedResources(for: container, includes: includes, options: options)
        }
    }

    // Returns first level of includes, for example ["author.car.media", "media"] will
    // return ["author", "media"]
    func rootIncludes(from includes: [String]) -> [String: [String]] {
        return includes
            .reduce(into: [String: [String]]()) { results, include in
                var items = include
                    .split(separator: HalleyConsts.includeSeparator)
                    .map(String.init)
                guard items.isEmpty == false else { return }
                let root = items.removeFirst()
                let currentValues = results[root, default: []]
                results[root] = currentValues + [items.joined(separator: String(HalleyConsts.includeSeparator))]
            }
    }
}

// MARK: - To one resource

private extension Traverser {

    func fetchSingleResourceLinkedResources(
        for resource: ResourceContainer,
        includes: [String],
        options: HalleyKit.Options
    ) throws -> AnyPublisher<JSONResult, Never> {
        let linksToFetch = singleResourceLinksToFetch(for: resource, includes: includes, options: options)
        #warning("TODO - use embedded to fill other info")
        let requests: [AnyPublisher<LinkResponse, Never>] = try linksToFetch.map { link in
            let url = try link.resolvedUrl()
            return self
                .resource(from: url, includes: link.includes)
                .map { LinkResponse(relationship: link.relationship, result: $0) }
                .eraseToAnyPublisher()
        }
        guard requests.isEmpty == false else {
            return .success(resource.parameters)
        }
        return requests
            .zip()
            .map { responses -> Parameters in
                var responseModel = resource.parameters
                responses.forEach { responseModel[$0.relationship] = $0.response }
                return responseModel
            }
            .map { JSONResult.success($0) }
            .eraseToAnyPublisher()
    }

    // Filters out resource relationships that are already present in resource (_embedded) and covers the
    // case where includes and _links don't match
    func singleResourceLinksToFetch(
        for resource: ResourceContainer,
        includes: [String],
        options: HalleyKit.Options
    ) -> [LinkIncludesElement] {
        guard
            let _links = resource._links?.relationships,
            _links.isEmpty == false, includes.isEmpty == false
        else { return [] }

        let rootIncludes = rootIncludes(from: includes)
        // Fetch rels available only in both includes and links
        var relevantRels = Set(rootIncludes.keys).intersection(_links.keys)
        if options.preferEmbeddedOverLinkTraversing {
            relevantRels = relevantRels.filter { resource.hasEmbeddedRelationship($0) == false }
        }

        // Since we are parsing single resource, and it is checked before, only one link will be here
        // as per specification
        return zip(relevantRels, relevantRels.map { _links[$0]?.first })
            .compactMap { rel, link in
                link.flatMap {
                    LinkIncludesElement(
                        relationship: rel,
                        link: $0,
                        includes: rootIncludes[rel] ?? []
                    )
                }
            }
    }
}

// MARK: - To many resource

private extension Traverser {

    /// Returns nil if input resource is not a collection
    func containsCollectionType(
        for resource: ResourceContainer,
        options: HalleyKit.Options
    ) -> ToManyCollectionType? {
        // In case of embedded resources don't fetch links
        let embeddedResources = resource
            .parameters[HalleyConsts.embedded]
            .flatMap { $0 as? Parameters }
            .flatMap { $0[options.arrayKey] as? [Parameters] }
        if let embeddedResources = embeddedResources {
            return .embedded(resources: embeddedResources)
        }
        let embeddedLinks = resource
            .parameters[HalleyConsts.links]
            .flatMap { $0 as? Parameters }
            .flatMap { $0[options.arrayKey] as? [Parameters] }
        if embeddedLinks != nil, let parsedArrayLinks = resource._links?.relationships[options.arrayKey] {
            return .linked(links: parsedArrayLinks)
        }
        // Check if it is empty page, and if so - treat this response as an empty collection
        if isEmptyCollectionResource(resource, options: options) {
            return .embedded(resources: [])
        }
        return nil
    }

    func parseCollectionLinkedResources(
        for resource: ResourceContainer,
        type: ToManyCollectionType,
        includes: [String],
        options: HalleyKit.Options
    ) throws -> AnyPublisher<JSONResult, Never> {
        switch type {
        case .embedded(let embeddedResources):
#warning("TODO - embedded fetch includes")
            return .success(embeddedResources)
        case .linked(let links):
            return try fetchCollectionResources(at: links, includes: includes, options: options)
        }
    }

    func fetchCollectionResources(
        at links: [Link],
        includes: [String],
        options: HalleyKit.Options
    ) throws -> AnyPublisher<JSONResult, Never> {
        let requests: [AnyPublisher<JSONResult, Never>] = try links
            .map { resource(from: try $0.resolvedUrl(), includes: includes) }
            .map { $0.eraseToAnyPublisher() }

        guard requests.isEmpty == false else {
            return .success([])
        }
        return requests
            .zip()
            .map { $0.collect() }
            .eraseToAnyPublisher()
    }

    /// Checks if given resource has paging info - if not returns false
    /// If has, checks if totalElements == 0. Returns true if totalElements == 0, false otherwise
    func isEmptyCollectionResource(
        _ resource: ResourceContainer,
        options: HalleyKit.Options
    ) -> Bool {
        let pageInfo = resource.parameters[options.pageMetadataKey]
            .flatMap { $0 as? Parameters }
            .flatMap(PageMetadata.fromParameters(_:))
        if let pageInfo = pageInfo {
            return pageInfo.totalElements == 0
        } else {
            return false
        }
    }
}

// MARK: - Helpers

enum ToManyCollectionType {
    case embedded(resources: [Parameters])
    case linked(links: [Link])
}

struct LinkResponse {
    let relationship: String
    let result: JSONResult

    var response: Any? {
        try? result.get()
    }
}

struct LinkIncludesElement {
    let relationship: String
    let link: Link
    let includes: [String]

    func resolvedUrl() throws -> URL {
        return try link.resolvedUrl()
    }
}

class ResourceContainer {

    let parameters: Parameters
    let _links: Links?
    let _embedded: [String: Parameters]?

    init(_ parameters: Parameters) {
        self.parameters = parameters
        _links = try? parameters.decode(Links.self, at: HalleyConsts.links)
        _embedded = parameters[HalleyConsts.embedded] as? [String: Parameters]
    }

    func hasEmbeddedRelationship(_ relationship: String) -> Bool {
        return _embedded?[relationship] != nil
    }
}
