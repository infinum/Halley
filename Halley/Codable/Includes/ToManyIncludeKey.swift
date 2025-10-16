import Foundation

public struct ToManyIncludeKey<T: IncludeKey>: RawRepresentable, IncludeKey, Sendable {
    public typealias RawValue = String

    public let includeKey: String
    public var rawValue: String { includeKey }

    public init?(rawValue: String) {
        self.includeKey = rawValue.toManyInclude()
    }

    public init(_ key: String) {
        self.includeKey = key.toManyInclude()
    }

    public init(_ codingKey: T) {
        self.includeKey = codingKey.includeKey.toManyInclude()
    }
}

private extension String {

    func toManyInclude() -> String {
        return "[\(self)]"
    }
}
