import Foundation
import Combine

public protocol RequestContainerInterface {
    func cancelRequest()
}

public protocol RequesterInterface: AnyObject {
    func requestResource(
        at url: URL,
        completion: sending @escaping (Result<Data, Error>) -> Void
    ) -> RequestContainerInterface
}
