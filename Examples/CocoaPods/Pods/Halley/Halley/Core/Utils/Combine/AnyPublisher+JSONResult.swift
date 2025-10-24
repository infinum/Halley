import Foundation
import Combine

extension AnyPublisher where Output == JSONResult {

    static func success(_ object: Any) -> AnyPublisher<JSONResult, Never> {
        return Just(JSONResult.success(object)).eraseToAnyPublisher()
    }

    static func failure(_ error: Error) -> AnyPublisher<JSONResult, Never> {
        return Just(JSONResult.failure(error)).eraseToAnyPublisher()
    }
}
