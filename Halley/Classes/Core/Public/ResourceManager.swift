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
    ) -> AnyPublisher<Result<Parameters, Error>, Never> {
        return traverser
            .resource(
                from: url,
                includes: includes,
                options: options,
                cache: options.responseFromCache ? .init() : nil,
                linkResolver: linkResolver
            )
            .map(\.asDictionary)
            .eraseToAnyPublisher()
    }

    func resourceCollection(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) -> AnyPublisher<Result<[Parameters], Error>, Never> {
        return traverser
            .resourceCollection(
                from: url,
                includes: includes,
                options: options,
                cache: options.responseFromCache ? .init() : nil,
                linkResolver: linkResolver
            )
            .map(\.asArrayOfDictionaries)
            .eraseToAnyPublisher()
    }

    func resourceCollectionWithMetadata(
        from url: URL,
        includes: [String] = [],
        options: HalleyKit.Options = .default,
        linkResolver: LinkResolver = URLLinkResolver()
    ) -> AnyPublisher<Result<Parameters, Error>, Never> {
        return traverser
            .resourceCollectionWithMetadata(
                from: url,
                includes: includes,
                options: options,
                cache: options.responseFromCache ? .init() : nil,
                linkResolver: linkResolver
            )
            .map(\.asDictionary)
            .eraseToAnyPublisher()
    }
}
