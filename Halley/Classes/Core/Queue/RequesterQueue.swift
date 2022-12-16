import Foundation
import Combine
import CombineExt

// Shared Queue for all network request
class RequesterQueue {

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
    ) -> AnyPublisher<JSONResponse, Never> {
        if let json = cache?[url] {
            let response = JSONResponse.success(json)
            return Just(response).eraseToAnyPublisher()
        }
        let response = response(at: url, requester: requester)
            .map { $0.tryMap { try JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) } }
            .eraseToAnyPublisher()
        if let cache = cache {
            // Cache is thread-safe by design so no need for any kind of locks/queues
            return response
                .handleEvents(receiveOutput: { cache[url] = try? $0.get() })
                .eraseToAnyPublisher()
        } else {
            return response
        }
    }
}
