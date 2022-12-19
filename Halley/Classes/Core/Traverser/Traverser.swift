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
        options: HalleyKit.Options = .default,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) -> AnyPublisher<JSONResult, Never> {
        let rootIncludes = rootIncludes(from: includes)
        return resource(
            from: url,
            includes: Includes(values: rootIncludes, relationshipPath: nil),
            options: options,
            cache: cache,
            linkResolver: linkResolver
        )
    }

    func resourceCollection(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) -> AnyPublisher<JSONResult, Never> {
        let rootIncludes = rootIncludes(from: includes)
        return resourceCollection(
            from: url,
            includes: Includes(values: rootIncludes, relationshipPath: nil),
            options: options,
            cache: cache,
            linkResolver: linkResolver
        )
    }

    func resourceCollectionWithMetadata(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) -> AnyPublisher<JSONResult, Never> {
        let rootIncludes = rootIncludes(from: includes)
        return resourceCollectionWithMetadata(
            from: url,
            includes: Includes(values: rootIncludes, relationshipPath: nil),
            options: options,
            cache: cache,
            linkResolver: linkResolver
        )
    }
}

// MARK: - To one resource

private extension Traverser {

    func resource(
        from url: URL,
        includes: Includes,
        options: HalleyKit.Options = .default,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) -> AnyPublisher<JSONResult, Never> {
        return requesterQueue
            .jsonResponse(at: url, requester: requester, cache: cache)
            .subscribe(on: serializationQueue)
            .receive(on: serializationQueue)
            .flatMap { [weak self] result -> AnyPublisher<JSONResult, Never> in
                guard let self = self else { return .failure(HalleyKit.Error.deinited) }
                do {
                    let response = try result.asDictionary.get()
                    let container = ResourceContainer(response)
                    return try self.fetchSingleResourceLinkedResources(
                        for: container,
                        includes: includes,
                        options: options,
                        cache: cache,
                        linkResolver: linkResolver
                    )
                } catch let error {
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchSingleResourceLinkedResources(
        for resource: ResourceContainer,
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) throws -> AnyPublisher<JSONResult, Never> {
        let linksToFetch = singleResourceLinksToFetch(for: resource, includes: includes, options: options)
        let requests: [AnyPublisher<LinkResponse, Never>] = try linksToFetch.map { link in

            guard link.isEmbedded == false else {
                // Resource is embedded so we only need to handle their included links
                return try handleLinksOfEmbeddedResource(
                    for: resource,
                    linkElement: link,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
            }

            // Makes request to the included link
            let url = try linkResolver.resolveLink(link.link, relationshipPath: link.includes.relationshipPath)
            switch link.linkType {
            case .toOne:
                return self.resource(from: url, includes: link.includes, cache: cache, linkResolver: linkResolver)
                    .map { LinkResponse(relationship: link.relationship, result: $0) }
                    .eraseToAnyPublisher()
            case .toMany:
                return self.resourceCollection(from: url, includes: link.includes, cache: cache, linkResolver: linkResolver)
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
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) throws -> AnyPublisher<LinkResponse, Never> {
        let embeddedResource = resource
            .parameters[linkElement.relationship]
            .flatMap { $0 as? Parameters }
            .flatMap(ResourceContainer.init)

        guard let _embeddedResource = embeddedResource else {
            throw HalleyKit.Error.relationshipNotFound(data: resource)
        }

        switch linkElement.linkType {
        case .toOne:
            return
                try fetchSingleResourceLinkedResources(
                    for: _embeddedResource,
                    includes: linkElement.includes,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
                .map { LinkResponse(relationship: linkElement.relationship, result: $0) }
                .eraseToAnyPublisher()
        case .toMany:
            return
                try parseCollectionLinkedResources(
                    for: _embeddedResource,
                    includes: linkElement.includes,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
                .map { LinkResponse(relationship: linkElement.relationship, result: $0) }
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - To many resource

private extension Traverser {

    func resourceCollection(
        from url: URL,
        includes: Includes,
        options: HalleyKit.Options = .default,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) -> AnyPublisher<JSONResult, Never> {
        return requesterQueue
            .jsonResponse(at: url, requester: requester, cache: cache)
            .subscribe(on: serializationQueue)
            .receive(on: serializationQueue)
            .flatMap { [weak self] result -> AnyPublisher<JSONResult, Never> in
                guard let self = self else { return .failure(HalleyKit.Error.deinited) }
                do {
                    let response = try result.asDictionary.get()
                    let container = ResourceContainer(response)
                    return try self.parseCollectionLinkedResources(
                        for: container,
                        includes: includes,
                        options: options,
                        cache: cache,
                        linkResolver: linkResolver
                    )
                } catch let error {
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func parseCollectionLinkedResources(
        for resource: ResourceContainer,
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) throws -> AnyPublisher<JSONResult, Never> {

        let embeddedResources = resource
            .parameters[options.arrayKey]
            .flatMap { $0 as? [Parameters] }
            .flatMap { $0.map(ResourceContainer.init) }

        if let embeddedResources = embeddedResources {
            return try fetchLinksForEmbeddedResources(
                embeddedResources: embeddedResources,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        }

        let embeddedLinks = resource
            .parameters[HalleyConsts.links]
            .flatMap { $0 as? Parameters }
            .flatMap { $0[options.arrayKey] as? [Parameters] }

        if embeddedLinks != nil, let parsedArrayLinks = resource._links?.relationships[options.arrayKey] {
            return try fetchCollectionResources(
                at: parsedArrayLinks,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        }

        return .success([])
    }

    func fetchLinksForEmbeddedResources(
        embeddedResources: [ResourceContainer],
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) throws -> AnyPublisher<JSONResult, Never> {
        let requests = try embeddedResources.map({ (resource) in
            return try fetchSingleResourceLinkedResources(
                for: resource,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        })
        return requests
            .zip()
            .map { $0.collect() }
            .eraseToAnyPublisher()
    }

    func fetchCollectionResources(
        at links: [Link],
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) throws -> AnyPublisher<JSONResult, Never> {
        let parent = includes.relationshipPath
        let requests: [AnyPublisher<JSONResult, Never>] = try links
            .map {
                return resource(
                    from: try linkResolver.resolveLink($0, relationshipPath: parent),
                    includes: includes,
                    cache: cache,
                    linkResolver: linkResolver
                )
            }
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

// MARK: - To many resource w/ metadata


private extension Traverser {

    func resourceCollectionWithMetadata(
        from url: URL,
        includes: Includes,
        options: HalleyKit.Options = .default,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) -> AnyPublisher<JSONResult, Never> {
        return requesterQueue
            .jsonResponse(at: url, requester: requester, cache: cache)
            .subscribe(on: serializationQueue)
            .receive(on: serializationQueue)
            .flatMap { [weak self] result -> AnyPublisher<JSONResult, Never> in
                guard let self = self else { return .failure(HalleyKit.Error.deinited) }
                do {
                    let response = try result.asDictionary.get()
                    let container = ResourceContainer(response)
                    return try self
                        .parseCollectionLinkedResources(
                            for: container,
                            includes: includes,
                            options: options,
                            cache: cache,
                            linkResolver: linkResolver
                        )
                        .map { (result: JSONResult) -> JSONResult in
                            return result.asArrayOfDictionaries.map { items in
                                var newParameters = container.parameters
                                newParameters[options.arrayKey] = items
                                return newParameters as Any
                            }
                        }
                        .eraseToAnyPublisher()
                } catch let error {
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Helpers -

private extension Traverser {

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

    // Marks resource relationships that are already present in resource (_embedded) and covers the
    // case where includes and _links don't match
    func singleResourceLinksToFetch(
        for resource: ResourceContainer,
        includes: Includes,
        options: HalleyKit.Options
    ) -> [LinkIncludesElement] {
        guard
            let _links = resource._links?.relationships,
            _links.isEmpty == false, includes.values.isEmpty == false
        else { return [] }

        let includeValues = includes.values
        // Fetch rels available only in both includes and links
        let relevantRels: [Include] = includeValues.filter({ _links.keys.contains($0.key) })
        var embeddedRels: Set<String> = []
        if options.preferEmbeddedOverLinkTraversing {
            embeddedRels = Set(relevantRels.filter { resource.hasEmbeddedRelationship($0.key) == true }.map(\.key))
        }

        // Since we are parsing single resource, and it is checked before, only one link will be here
        // as per specification
        return zip(relevantRels, relevantRels.map { _links[$0.key]?.first })
            .compactMap { rel, link in
                guard let link = link else { return nil }
                let relIncludes = rootIncludes(from: rel.value ?? [])
                let relationshipPath = includes.path(for: rel.rawKey)
                return LinkIncludesElement(
                    relationship: rel.key,
                    link: link,
                    includes: Includes(values: relIncludes, relationshipPath: relationshipPath),
                    linkType: rel.type,
                    isEmbedded: embeddedRels.contains(rel.key)
                )
            }
    }
}
