import Foundation
import Combine

func throwError<T>(_ error: Error) throws -> T {
    throw error
}

func throwHalleyError<T>(_ error: HalleyKit.Error) throws -> T {
    throw error
}

extension AnyPublisher {

    static func just(_ value: Output) -> AnyPublisher<Output, Failure> {
        return Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    static func error(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}
