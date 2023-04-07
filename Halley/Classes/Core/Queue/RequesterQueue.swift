import Foundation

typealias JSONCache = Cache<URL, JSONResponse>

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
        #warning("TODO - cache")
        let operation = HALRequestOperation(url: url, requester: requester)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                operation.addCompletionHandler { continuation.resume(returning: $0) }
                lock.safe { queue.addOperation(operation) }
            }
        } onCancel: {
            operation.cancel()
        }
    }
}
