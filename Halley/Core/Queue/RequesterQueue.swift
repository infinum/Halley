import Foundation
import Combine

typealias JSONCache = Cache<URL, AnyPublisher<JSONResponse, Never>>

// Shared Queue for all network request

final class RequesterQueue: Sendable {

    // MARK: - Singleton

    static let shared = RequesterQueue()

    // MARK: - Internals

    private let lock: NSLock
    private let underlyingDispatchQueue: DispatchQueue
    private let queue: OperationQueue

    private init() {
        self.lock = NSLock()
        self.underlyingDispatchQueue = DispatchQueue(
            label: "com.hal.networking.queue",
            qos: .userInitiated,
            attributes: .concurrent
        )
        self.queue = OperationQueue()
        self.queue.underlyingQueue = underlyingDispatchQueue
        self.queue.maxConcurrentOperationCount = 10
        self.queue.qualityOfService = .userInitiated
    }

    func response(at url: URL, requester: RequesterInterface) -> AnyPublisher<APIResponse, Never> {
        return AnyPublisher<APIResponse, Never>.create { [lock, queue] subscriber in
            nonisolated(unsafe) let subscriber = subscriber
            let operation = HALRequestOperation(
                url: url,
                requester: requester
            ) {
                subscriber.send($0)
                subscriber.send(completion: .finished)
            }
            lock.safe { queue.addOperation(operation) }
            return AnyCancellable { operation.cancel() }
        }
    }

    func jsonResponse(
        at url: URL,
        requester: RequesterInterface,
        cache: JSONCache?
    ) -> some Publisher<JSONResponse, Never> {
        if let chain = cache?[url] {
            return chain
        }
        let response = response(at: url, requester: requester)
            .map { $0.tryMap { try JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) } }
            .share(replay: 1) // Replay last value when subscribed on cache event
            .eraseToAnyPublisher()
        cache?[url] = response
        return response
    }
}
