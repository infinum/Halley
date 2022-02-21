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
                    let response = try result.asDictionary.get()
                    let container = ResourceContainer(response)
                    return try self.fetchSingleResourceLinkedResources(for: container, includes: includes, options: options)
                } catch let error {
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func resourceCollection(
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
                    let response = try result.asDictionary.get()
                    let container = ResourceContainer(response)
                    return try self.parseCollectionLinkedResources(for: container, includes: includes, options: options)
                } catch let error {
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
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
        let requests: [AnyPublisher<LinkResponse, Never>] = try linksToFetch.map { link in

            guard link.isEmbedded == false else {
                // Resource is embedded so we only need to handle their included links
                return try handleLinksOfEmbeddedResource(for: resource, linkElement: link, options: options)
            }

            // Makes request to the included link
            let url = try link.resolvedUrl()
            switch link.linkType {
            case .toOne:
                return self.resource(from: url, includes: link.includes)
                    .map { LinkResponse(relationship: link.relationship, result: $0) }
                    .eraseToAnyPublisher()
            case .toMany:
                return self.resourceCollection(from: url, includes: link.includes)
                    .map { LinkResponse(relationship: link.relationship, result: $0) }
                    .eraseToAnyPublisher()
            }
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

    /// Request links for resources that where embedded
    func handleLinksOfEmbeddedResource(
        for resource: ResourceContainer,
        linkElement: LinkIncludesElement,
        options: HalleyKit.Options
    ) throws -> AnyPublisher<LinkResponse, Never> {
        let embeddedResource = resource.parameters[linkElement.relationship]
            .flatMap({ $0 as? Parameters })
            .flatMap(ResourceContainer.init)

        guard let _embeddedResource = embeddedResource else {
            throw HalleyKit.Error.relationshipNotFound(data: resource)
        }

        return try fetchSingleResourceLinkedResources(for: _embeddedResource, includes: linkElement.includes, options: options)
            .map { LinkResponse(relationship: linkElement.relationship, result: $0) }
            .eraseToAnyPublisher()
    }

    // Marks resource relationships that are already present in resource (_embedded) and covers the
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
        let relevantRels: [Include] = rootIncludes.filter({ _links.keys.contains($0.key) })
        var embeddedRels: Set<String> = []
        if options.preferEmbeddedOverLinkTraversing {
            embeddedRels = Set(relevantRels.filter { resource.hasEmbeddedRelationship($0.key) == true }.map(\.key))
        }

        // Since we are parsing single resource, and it is checked before, only one link will be here
        // as per specification
        return zip(relevantRels, relevantRels.map { _links[$0.key]?.first })
            .compactMap { rel, link in
                link.flatMap {
                    LinkIncludesElement(
                        relationship: rel.key,
                        link: $0,
                        includes: rel.value ?? [],
                        linkType: rel.type,
                        isEmbedded: embeddedRels.contains(rel.key)
                    )
                }
            }
    }

}

// MARK: - To many resource

private extension Traverser {

    func parseCollectionLinkedResources(
        for resource: ResourceContainer,
        includes: [String],
        options: HalleyKit.Options
    ) throws -> AnyPublisher<JSONResult, Never> {

        let embeddedResources = resource
            .parameters[HalleyConsts.embedded]
            .flatMap { $0 as? Parameters }
            .flatMap { $0[options.arrayKey] as? [Parameters] }
            .flatMap({ $0.map(ResourceContainer.init) })

        if let embeddedResources = embeddedResources {
            return try fetchLinksForEmbeddedResources(embeddedResources: embeddedResources, includes: includes, options: options)
        }

        let embeddedLinks = resource
            .parameters[HalleyConsts.links]
            .flatMap { $0 as? Parameters }
            .flatMap { $0[options.arrayKey] as? [Parameters] }

        if embeddedLinks != nil, let parsedArrayLinks = resource._links?.relationships[options.arrayKey] {
            return try fetchCollectionResources(at: parsedArrayLinks, includes: includes, options: options)
        }

        return .success([])
    }

    func fetchLinksForEmbeddedResources(
        embeddedResources: [ResourceContainer],
        includes: [String],
        options: HalleyKit.Options
    ) throws -> AnyPublisher<JSONResult, Never> {
        let requests = try embeddedResources.map({ (resource) in
            return try fetchSingleResourceLinkedResources(for: resource, includes: includes, options: options)
        })
        return requests
            .zip()
            .map { $0.collect() }
            .eraseToAnyPublisher()
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
}

// MARK: - Helpers -

private extension Traverser {

    // Returns first level of includes, for example ["author.car.media", "media"] will
    // return ["author", "media"]
    func rootIncludes(from includes: [String]) -> [Include] {
        return includes
            .reduce(into: [String: [String]]()) { results, include in
                var items = include
                    .split(separator: HalleyConsts.includeSeparator)
                    .map(String.init)
                guard items.isEmpty == false else { return }
                let root = items.removeFirst()
                let currentValues = results[root, default: []]
                let childIncludes = items.isEmpty ? [] : [items.joined(separator: String(HalleyConsts.includeSeparator))]
                results[root] = currentValues + childIncludes
            }
            .map({ Include(key: $0.key, values: $0.value) })
    }
}

// MARK: - Helpers

enum ToManyCollectionType {
    case embedded(resources: [Parameters])
    case linked(links: [Link])
}

/// Model for handling includes
/// To specify if a include is `toMany`, the key must be inside `[]` (eg. `[images]`)
struct Include {
    let type: LinkType
    let value: [String]?
    let key: String

    init(key: String, values: [String]?) {
        let isArray = key.hasPrefix("[") && key.hasSuffix("]")
        type = isArray ? .toMany : .toOne
        value = values
        self.key = key.trimmingCharacters(in: .init(charactersIn: "[]"))
    }
}

enum LinkType {
    case toOne
    case toMany
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
    let linkType: LinkType
    let isEmbedded: Bool

    func resolvedUrl() throws -> URL {
        return try link.resolvedUrl()
    }
}

class ResourceContainer {

    let parameters: Parameters
    let _links: Links?
    let _embedded: [String: Parameters]?

    init(_ parameters: Parameters) {
        var _parameters = parameters
        _links = try? parameters.decode(Links.self, at: HalleyConsts.links)
        _embedded = parameters[HalleyConsts.embedded] as? [String: Parameters]
        // Adds embedded resources to the result dictionary
        _embedded?.forEach({ _parameters[$0.key] = $0.value })
        self.parameters = _parameters
    }

    func hasEmbeddedRelationship(_ relationship: String) -> Bool {
        return _embedded?[relationship] != nil
    }
}

protocol LinkResolver {
    func resolveLink(_ link: String) throws -> URL
}
