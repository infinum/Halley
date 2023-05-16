import Foundation
import Combine

public class ResourceManager {

    private let requester: RequesterInterface
    private let traverser: Traverser
    private let requesterQueue: RequesterQueue = .shared

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
    ) -> some Publisher<Result<Parameters, Error>, Never> {
        // Deffer initial request to allow retry on client side - responses inside Halley
        // are shared and replied which would cause the endless retry loop if initial request
        // fails - it would repeat error all over again. Deferred will recreate whole request again.
        return Deferred { [weak self] in
            guard let self else {
                return Just(Result<Parameters, Error>.failure(HalleyKit.Error.deinited)).eraseToAnyPublisher()
            }
            let cache = options.responseFromCache ? JSONCache() : nil
            return self.traverser
                .resource(
                    from: url,
                    includes: includes,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
                .map(\.asDictionary)
                .clearCacheOnCompletion(cache)
                .eraseToAnyPublisher()
        }
    }

    func resourceCollection(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) -> some Publisher<Result<[Parameters], Error>, Never> {
        // Deffer initial request to allow retry on client side - responses inside Halley
        // are shared and replied which would cause the endless retry loop if initial request
        // fails - it would repeat error all over again. Deferred will recreate whole request again.
        return Deferred { [weak self] in
            guard let self else {
                return Just(Result<[Parameters], Error>.failure(HalleyKit.Error.deinited)).eraseToAnyPublisher()
            }
            let cache = options.responseFromCache ? JSONCache() : nil
            return self.traverser
                .resourceCollection(
                    from: url,
                    includes: includes,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
                .map(\.asArrayOfDictionaries)
                .clearCacheOnCompletion(cache)
                .eraseToAnyPublisher()
        }
    }

    func resourceCollectionWithMetadata(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) -> some Publisher<Result<Parameters, Error>, Never> {
        // Deffer initial request to allow retry on client side - responses inside Halley
        // are shared and replied which would cause the endless retry loop if initial request
        // fails - it would repeat error all over again. Deferred will recreate whole request again.
        return Deferred { [weak self] in
            guard let self else {
                return Just(Result<Parameters, Error>.failure(HalleyKit.Error.deinited)).eraseToAnyPublisher()
            }
            let cache = options.responseFromCache ? JSONCache() : nil
            return self.traverser
                .resourceCollectionWithMetadata(
                    from: url,
                    includes: includes,
                    options: options,
                    cache: cache,
                    linkResolver: linkResolver
                )
                .map(\.asDictionary)
                .clearCacheOnCompletion(cache)
                .eraseToAnyPublisher()
        }
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
