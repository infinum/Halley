import Foundation
import Combine

typealias JSONCache = Cache<URL, AnyPublisher<JSONResponse, Never>>

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

    // MARK: - Async variant

    func response(
        at url: URL,
        requester: RequesterInterface,
        cache: JSONCache?
    ) async -> JSONResponse {
        do {
            let possibleResponse = try await combineResponse(at: url, requester: requester, cache: cache).asyncStream()
                .first { _ in true }
            return possibleResponse ?? .failure(HalleyKit.Error.noResponse)
        } catch {
            return .failure(error)
        }
    }

    func combineResponse(
        at url: URL,
        requester: RequesterInterface,
        cache: JSONCache?
    ) -> AnyPublisher<JSONResponse, Never> {
        if let chain = cache?[url] {
            return chain
        }
        let response = AnyPublisher<JSONResponse, Never>
            .create { [lock, queue] subscriber in
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
            .share(replay: 1) // Replay last value when subscribed on cache event
            .eraseToAnyPublisher()
        cache?[url] = response
        return response
    }
}

extension Publisher {

    func asyncStream() -> AsyncThrowingStream<Output, Error> {
        let holder = CancellableHolder()
        return AsyncThrowingStream { continuation in
            holder.cancellable = self.sink { completion in
                switch completion {
                case .failure(let error):
                    continuation.finish(throwing: error)
                case .finished:
                    continuation.finish(throwing: nil)
                }
            } receiveValue: { value in
                continuation.yield(value)
            }
            continuation.onTermination = { @Sendable _ in
                holder.cancellable?.cancel()
                holder.cancellable = nil
            }
        }
    }
}

private final class CancellableHolder {
    var cancellable: AnyCancellable?
}
