import Foundation

public protocol IncludeKey: Hashable {
    var includeKey: String { get }
}

public struct CustomIncludeKey<T: IncludeKey>: RawRepresentable, IncludeKey {
    public typealias RawValue = String

    public let includeKey: String
    public var rawValue: String { includeKey }

    public init?(rawValue: String) {
        self.includeKey = rawValue
    }

    public init(_ key: String) {
        self.includeKey = key
    }

    public init(_ codingKey: T) {
        self.includeKey = codingKey.includeKey
    }
}

extension String: IncludeKey {
    public var includeKey: String { self }
}

public extension IncludeKey where Self: CodingKey {
    var includeKey: String { stringValue }
}

public extension IncludeKey {
    var toMany: any IncludeKey { ToManyIncludeKey(includeKey) }
}

// MARK: - IncludeTypeInterface

public protocol IncludeTypeInterface {
    associatedtype IncludeCodingKey: IncludeKey
    typealias Keys = IncludeCodingKey
    typealias AnyKey = CustomIncludeKey<IncludeCodingKey>

    @IncludesBuilder<IncludeCodingKey> func prepareIncludes() -> [IncludeField]
}

// MARK: - IncludeTypeInterface

public protocol IncludeableType {
    associatedtype IncludeType: IncludeTypeInterface
}

public extension IncludeableType where Self: HalleyCodable {

    @inlinable
    func links(for codingKey: IncludeType.IncludeCodingKey) -> [Link]? {
        return _links?.links(for: codingKey.includeKey)
    }

    @inlinable
    func link(for codingKey: IncludeType.IncludeCodingKey) -> Link? {
        return _links?.link(for: codingKey.includeKey)
    }

    @inlinable
    func href(for codingKey: IncludeType.IncludeCodingKey) -> String? {
        return _links?.href(for: codingKey.includeKey)
    }

    @inlinable
    func isTemplated(for codingKey: IncludeType.IncludeCodingKey) -> Bool? {
        return _links?.isTemplated(for: codingKey.includeKey)
    }

    @inlinable
    func asURL(for codingKey: IncludeType.IncludeCodingKey, with variables: [String: Any]) throws -> URL? {
        return try _links?.asURL(for: codingKey.includeKey, with: variables)
    }

    @inlinable
    func asURL(for codingKey: IncludeType.IncludeCodingKey, with queryItems: [URLQueryItem]) throws -> URL? {
        return try _links?.asURL(for: codingKey.includeKey, with: queryItems)
    }
}
