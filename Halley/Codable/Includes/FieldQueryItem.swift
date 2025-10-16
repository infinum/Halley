import Foundation

public struct FieldQueryItem: Sendable {
    public let key: String
    public let value: String

    public var asQueryItem: URLQueryItem { .init(name: key, value: value) }

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public init(key: String, values: [String]) {
        self.key = key
        self.value = values.joined(separator: ",")
    }
}

extension FieldQueryItem: Equatable {

    public static func == (rhs: FieldQueryItem, lhs: FieldQueryItem) -> Bool {
        return rhs.key == lhs.key
    }
}
