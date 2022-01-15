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

            return AnyCancellable {
                operation.cancel()
            }
        }
    }

    func jsonResponse(at url: URL, requester: RequesterInterface) -> AnyPublisher<JSONResponse, Never> {
        return response(at: url, requester: requester)
            .map { $0.tryMap { try JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) } }
            .eraseToAnyPublisher()
    }
}
