import Foundation

func throwError<T>(_ error: Error) throws -> T {
    throw error
}

func throwHalleyError<T>(_ error: HalleyKit.Error) throws -> T {
    throw error
}
