import Foundation
import Combine

class HALRequestOperation: ConcurrentOperation {

    typealias CompletionHanlder = (JSONResponse) -> Void

    private let lock: NSLock = .init()
    private let url: URL
    private let requester: RequesterInterface
    private var completionHandlers: [CompletionHanlder]

    // Request should not be started at init, hence filling this in main
    private var requestContainer: RequestContainerInterface?

    init(url: URL, requester: RequesterInterface) {
        self.url = url
        self.requester = requester
        self.completionHandlers = []
        super.init()
    }

    override func main() {
        requestContainer = requester.requestResource(at: url) { [weak self] dataResult in
            guard let self = self else { return }
            self.finish()
            let jsonResult = dataResult
                .tryMap { try JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            self.lock.safe {
                self.completionHandlers.forEach { $0(jsonResult) }
            }
        }
    }

    func addCompletionHandler(_ completionHandler: @escaping CompletionHanlder) {
        lock.safe {
            completionHandlers.append(completionHandler)
        }
    }

    override func cancel() {
        if !isFinished {
            requestContainer?.cancelRequest()
        }
        super.cancel()
    }
}
