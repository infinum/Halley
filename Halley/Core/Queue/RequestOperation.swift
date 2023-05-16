import Foundation
import Combine

class HALRequestOperation: ConcurrentOperation {

    typealias CompletionHanlder = (JSONResponse) -> Void

    private let url: URL
    private let requester: RequesterInterface
    private let completionHandler: CompletionHanlder

    // Request should not be started at init, hence filling this in main
    private var requestContainer: RequestContainerInterface?

    init(
        url: URL,
        requester: RequesterInterface,
        completionHandler: @escaping CompletionHanlder
    ) {
        self.url = url
        self.requester = requester
        self.completionHandler = completionHandler
        super.init()
    }

    override func main() {
        requestContainer = requester.requestResource(at: url) { [weak self] dataResult in
            guard let self = self else { return }
            self.finish()
            let jsonResult = dataResult
                .tryMap { try JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            self.completionHandler(jsonResult)
        }
    }

    override func cancel() {
        if !isFinished {
            requestContainer?.cancelRequest()
        }
        super.cancel()
    }
}
