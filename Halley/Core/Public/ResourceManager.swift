import Foundation

public class ResourceManager {

    private let requester: RequesterInterface
    private let traverser: Traverser

    public init(requester: RequesterInterface) {
        self.traverser = Traverser(requester: requester)
        self.requester = requester
    }
}

public extension ResourceManager {

    func resource(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) async -> Result<Parameters, Error> {
        let cache = options.responseFromCache ? JSONCache() : nil
        defer { cache?.clear() }
        return await traverser
            .resource(
                from: url,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
            .asDictionary
    }

    func resourceCollection(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) async -> Result<[Parameters], Error> {
        let cache = options.responseFromCache ? JSONCache() : nil
        defer { cache?.clear() }
        return await traverser
            .resourceCollection(
                from: url,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
            .asArrayOfDictionaries
    }

    func resourceCollectionWithMetadata(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) async -> Result<Parameters, Error> {
        let cache = options.responseFromCache ? JSONCache() : nil
        defer { cache?.clear() }
        return await traverser
            .resourceCollectionWithMetadata(
                from: url,
                includes: includes,
                options: options,
                cache: cache,
                linkResolver: linkResolver
            )
            .asDictionary
    }
}
