import Foundation

typealias JSONResult = Result<Any, Error>

class Traverser {

    private let requester: RequesterInterface
    private let requesterQueue: RequesterQueue = .shared

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
    ) async -> JSONResult {
        return await resource(
            from: url,
            includes: Includes(values: rootIncludes(from: includes), relationshipPath: nil),
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
    ) async -> JSONResult {
        return await resourceCollection(
            from: url,
            includes: Includes(values: rootIncludes(from: includes), relationshipPath: nil),
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
    ) async -> JSONResult {
        return await resourceCollectionWithMetadata(
            from: url,
            includes: Includes(values: rootIncludes(from: includes), relationshipPath: nil),
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
    ) async -> JSONResult {
        let result = await requesterQueue.response(at: url, requester: requester, cache: cache)
        do {
            return try await fetchSingleResourceLinkedResources(
                for: ResourceContainer(try result.asDictionary.get()),
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        } catch let error {
            return .failure(error)
        }
    }

    func fetchSingleResourceLinkedResources(
        for resource: ResourceContainer,
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> JSONResult {
        let linksToFetch = singleResourceLinksToFetch(for: resource, includes: includes, options: options)
        guard linksToFetch.isEmpty == false else {
            return .success(resource.parameters)
        }
        let response = try await linksToFetch
            .concurrentMap { [self] link -> LinkResponse in
                try await fetchLinkedResource(
                    for: resource,
                    linkElement: link,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
            }
            .reduce(into: resource.parameters) { $0[$1.relationship] = $1.response }
        return .success(response)
    }

    func fetchLinkedResource(
        for resource: ResourceContainer,
        linkElement link: LinkIncludesElement,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> LinkResponse {
        guard link.isEmbedded == false else {
            // Resource is embedded so we only need to handle their included links
            return try await handleLinksOfEmbeddedResource(
                for: resource,
                linkElement: link,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        }
        // Makes request to the included link
        let url = try linkResolver.resolveLink(link.link, relationshipPath: link.includes.relationshipPath)
        let result: JSONResult
        switch link.linkType {
        case .toOne:
            result = await self.resource(from: url, includes: link.includes, cache: cache, linkResolver: linkResolver)
        case .toMany:
            result = await self.resourceCollection(from: url, includes: link.includes, cache: cache, linkResolver: linkResolver)
        }
        return LinkResponse(relationship: link.relationship, result: result)
    }

    /// Request links for resources that where embedded
    func handleLinksOfEmbeddedResource(
        for resource: ResourceContainer,
        linkElement: LinkIncludesElement,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> LinkResponse {
        switch linkElement.linkType {
        case .toOne:
            return try await parseSingleEmbeddedResource(
                for: resource,
                linkElement: linkElement,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        case .toMany:
            return try await parseManyEmbeddedResources(
                for: resource,
                linkElement: linkElement,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        }
    }

    func parseSingleEmbeddedResource(
        for resource: ResourceContainer,
        linkElement: LinkIncludesElement,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> LinkResponse {
        let embeddedResource = resource
            .parameters[linkElement.relationship]
            .flatMap { $0 as? Parameters }
            .flatMap(ResourceContainer.init)
        guard let embeddedResource else {
            throw HalleyKit.Error.relationshipNotFound(data: resource)
        }
        let result = try await fetchSingleResourceLinkedResources(
            for: embeddedResource,
            includes: linkElement.includes,
            options: options,
            cache: cache,
            linkResolver: linkResolver
        )
        return LinkResponse(relationship: linkElement.relationship, result: result)
    }

    func parseManyEmbeddedResources(
        for resource: ResourceContainer,
        linkElement: LinkIncludesElement,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> LinkResponse {
        let resourceParameters = resource.parameters[linkElement.relationship]
        if let singleResource = resourceParameters as? Parameters {
            // This represents an embedded page with metadata as an embedded structure. For example:
            //    "_embedded": {
            //        "some_items": {
            //            "_embedded": {
            //                "item": [...]
            //            },
            //            "_links": { ... },
            //            "page": { ... }
            //        }
            //    }
            let result = try await parseCollectionLinkedResources(
                for: ResourceContainer(singleResource),
                includes: linkElement.includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
            return LinkResponse(relationship: linkElement.relationship, result: result)
        } else if let manyResources = resourceParameters as? [Parameters] {
            // This represents an embedded collection with items, without any additional metadata
            // "_embedded": {
            //    "some_items":  [{
            //        "_embedded": { ... }
            //    }]
            // }
            let result = try await fetchLinksForEmbeddedResources(
                embeddedResources: manyResources.map(ResourceContainer.init),
                includes: linkElement.includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
            return LinkResponse(relationship: linkElement.relationship, result: result)
        } else {
            throw HalleyKit.Error.relationshipNotFound(data: resource)
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
    ) async -> JSONResult {
        let result = await requesterQueue.response(at: url, requester: requester, cache: cache)
        do {
            return try await parseCollectionLinkedResources(
                for: ResourceContainer(try result.asDictionary.get()),
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        } catch let error {
            return .failure(error)
        }
    }

    func parseCollectionLinkedResources(
        for resource: ResourceContainer,
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> JSONResult {
        let embeddedResources = resource
            .parameters[options.arrayKey]
            .flatMap { $0 as? [Parameters] }
            .flatMap { $0.map(ResourceContainer.init) }

        if let embeddedResources = embeddedResources {
            return try await fetchLinksForEmbeddedResources(
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
            return try await fetchCollectionResources(
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
    ) async throws -> JSONResult {
        // Ensure .zip() doesn't end up with Empty Publisher which produces no elements
        // and ends whole pipeline
        guard embeddedResources.isEmpty == false else {
            return .success([])
        }
        let responses = try await embeddedResources.concurrentMap { [self] resource in
            return try await fetchSingleResourceLinkedResources(
                for: resource,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
        }
        return responses.collect()
    }

    func fetchCollectionResources(
        at links: [Link],
        includes: Includes,
        options: HalleyKit.Options,
        cache: JSONCache?,
        linkResolver: LinkResolver
    ) async throws -> JSONResult {
        let parent = includes.relationshipPath
        guard links.isEmpty == false else {
            return .success([])
        }
        let responses = try await links.concurrentMap { [self] in
            return await self.resource(
                from: try linkResolver.resolveLink($0, relationshipPath: parent),
                includes: includes,
                cache: cache,
                linkResolver: linkResolver
            )
        }
        return responses.collect()
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
    ) async -> JSONResult {
        let result = await requesterQueue.response(at: url, requester: requester, cache: cache)
        do {
            let response = try result.asDictionary.get()
            let container = ResourceContainer(response)
            let parsedResult = try await parseCollectionLinkedResources(
                for: container,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
            return parsedResult.asArrayOfDictionaries.map { items in
                var newParameters = container.parameters
                newParameters[options.arrayKey] = items
                return newParameters as Any
            }
        } catch let error {
            return .failure(error)
        }
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
            .map { Include(key: $0.key, values: $0.value) }
    }

    // Marks resource relationships that are already present in resource (_embedded) and covers the
    // case where includes and _links don't match
    func singleResourceLinksToFetch(
        for resource: ResourceContainer,
        includes: Includes,
        options: HalleyKit.Options
    ) -> [LinkIncludesElement] {
        // Skip if there is no relationship requested to be included
        let includeValues = includes.values
        guard includeValues.isEmpty == false else { return [] }

        // In case there are no links to fetch, skip
        guard
            let _links = resource._links?.relationships,
            _links.isEmpty == false
        else { return [] }

        // We support fetching only those relationships which have a link
        let relevantRels: [Include] = includeValues.filter {
            _links.keys.contains($0.key)
        }

        let embeddedRels: Set<String>
        if options.preferEmbeddedOverLinkTraversing {
            embeddedRels = Set(relevantRels.filter { resource.hasEmbeddedRelationship($0.key) }.map(\.key))
        } else {
            embeddedRels = []
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
