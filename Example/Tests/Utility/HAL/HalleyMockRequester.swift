import Foundation
import Halley

class HalleyMockRequester: RequesterInterface {

    let registeredMocks: HalleyMockReferences

    init(registeredMocks: HalleyMockReferences) {
        self.registeredMocks = registeredMocks
    }

    func requestResource(
        at url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> RequestContainerInterface {
        let path = url.absoluteString
        // Simulate API call
        DispatchQueue.main.async { [self] in
            do {
                let data = try registeredMocks[path]
                    .orThrow(HalleyTestError.unableToFindMockFile(path))
                    .load()
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
        return HalleyMockRequestContainer()
    }
}

class HalleyMockRequestContainer: RequestContainerInterface {

    var requestCanceled: Bool = false

    func cancelRequest() {
        self.requestCanceled = true
    }
}

extension Optional {

    func orThrow<E: Error>(_ errorClosure: @autoclosure () -> E) throws -> Wrapped {
        guard let value = self else {
            throw errorClosure()
        }
        return value
    }
}
