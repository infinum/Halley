import Foundation
import Combine

func throwError<T>(_ error: Error) throws -> T {
    throw error
}

func throwHalleyError<T>(_ error: HalleyKit.Error) throws -> T {
    throw error
}

extension AnyPublisher {

    static func error(_ error: HalleyKit.Error) -> AnyPublisher<Output, Error> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}
