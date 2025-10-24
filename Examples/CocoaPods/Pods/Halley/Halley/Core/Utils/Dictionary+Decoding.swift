import Foundation

extension Dictionary where Key == String {

    func decode<T: Decodable>(_ type: T.Type, at key: String) throws -> T {
        guard
            let value = self[key],
            JSONSerialization.isValidJSONObject(value)
        else { throw HalleyKit.Error.cantProcess }
        let data = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
