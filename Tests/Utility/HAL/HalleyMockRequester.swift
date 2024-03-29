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
                let mock = try registeredMocks[path]
                    .orThrow(HalleyTestsError.conditionFailed("Unbable to find a mock for \(path)"))
                let data = try mock.load()
                completion(.success(data))
            } catch {
                completion(.failure(error))
            }
        }
        return HalleyMockRequestContainer()
    }
}

struct HalleyMockRequestContainer: RequestContainerInterface {

    func cancelRequest() {
        // Do nothing
    }
}
