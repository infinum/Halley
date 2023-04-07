import Foundation
import Combine

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
    ) -> AnyPublisher<Result<Parameters, Error>, Never> {
#warning("TODO")
        fatalError()
//        let cache = options.responseFromCache ? JSONCache() : nil
//        return traverser
//            .resource(
//                from: url,
//                includes: includes,
//                options: options,
//                cache: cache,
//                linkResolver: linkResolver
//            )
//            .map(\.asDictionary)
//            .clearCacheOnCompletion(cache)
    }

    func resourceCollection(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) -> AnyPublisher<Result<[Parameters], Error>, Never> {
#warning("TODO")
        fatalError()
//        let cache = options.responseFromCache ? JSONCache() : nil
//        return traverser
//            .resourceCollection(
//                from: url,
//                includes: includes,
//                options: options,
//                cache: cache,
//                linkResolver: linkResolver
//            )
//            .map(\.asArrayOfDictionaries)
//            .clearCacheOnCompletion(cache)
    }

    func resourceCollectionWithMetadata(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) -> AnyPublisher<Result<Parameters, Error>, Never> {
#warning("TODO")
        fatalError()
//        let cache = options.responseFromCache ? JSONCache() : nil
//        return traverser
//            .resourceCollectionWithMetadata(
//                from: url,
//                includes: includes,
//                options: options,
//                cache: cache,
//                linkResolver: linkResolver
//            )
//            .map(\.asDictionary)
//            .clearCacheOnCompletion(cache)
    }
}

private extension Publisher {

    // Cache holds a reference to Publisher which again needs to keep a reference
    // to a publisher. That way we are creating retain cycle so it is crucial to
    // clear the cache after use.
    func clearCacheOnCompletion(_ cache: JSONCache?) -> some Publisher<Output, Failure> {
        guard let cache = cache else { return self.eraseToAnyPublisher() }
        return self
            .handleEvents(
                receiveCompletion: { _ in
                    cache.clear()
                }, receiveCancel: {
                    cache.clear()
                }
            )
            .eraseToAnyPublisher()
    }
}
