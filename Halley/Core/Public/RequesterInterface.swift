import Foundation

public protocol RequestContainerInterface {
    func cancelRequest()
}

public protocol RequesterInterface: AnyObject {
    func requestResource(
        at url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> RequestContainerInterface
}
