import Foundation
import Combine

extension JSONResult {

    var asDictionary: Result<Parameters, Error> {
        tryMap { try $0 as? Parameters ?? throwHalleyError(.notDictionary(data: $0)) }
    }

    var asArray: Result<[Any], Error> {
        tryMap { try $0 as? [Any] ?? throwHalleyError(.notArray(data: $0)) }
    }

    var asArrayOfDictionaries: Result<[Parameters], Error> {
        tryMap { try $0 as? [Parameters] ?? throwHalleyError(.notArrayOfDictionaries(data: $0)) }
    }
}

extension Collection where Element == JSONResult {

    /// Collects all responses and joins them as a single array. In case if any
    /// of responses has error, it will return .failure
    /// - Returns: `.success` if all responses are successful, `.failure` if any of responses have failed
    func collect() -> JSONResult {
        do {
            let joined = try map { try $0.get() }
            return .success(joined)
        } catch let error {
            return .failure(error)
        }
    }
}
