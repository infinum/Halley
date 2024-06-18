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

    /// Collects all responses and joins them as a single array. Depending on the `options` property
    /// `failWhenAnyNestedRequestErrors`, method will return a success or failure.
    ///
    /// - Returns: `.success` if all responses are successful, `.failure` if any response
    /// has failed and the `failWhenAnyNestedRequestErrors` property is set to `true`
    func collect(options: HalleyKit.Options) -> JSONResult {
        do {
            let joined = try compactMap {
                options.failWhenAnyNestedRequestErrors ? try $0.get() : try? $0.get()
            }
            return .success(joined)
        } catch let error {
            return .failure(error)
        }
    }
}
