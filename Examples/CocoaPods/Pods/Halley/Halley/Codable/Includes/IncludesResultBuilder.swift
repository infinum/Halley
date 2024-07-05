import Foundation

@resultBuilder
public enum IncludesBuilder<IncludeCodingKey: IncludeKey> {

    public static func buildBlock(_ components: [IncludeField]...) -> [IncludeField] {
        return components.flatMap { $0 }
    }

    // MARK: Single key support

    public static func buildExpression(_ rootKey: IncludeCodingKey) -> [IncludeField] {
        return [.init(key: rootKey.includeKey)]
    }

    public static func buildExpression(_ codingKeys: [IncludeCodingKey]) -> [IncludeField] {
        return codingKeys.map { IncludeField(key: $0.includeKey) }
    }

    public static func buildExpression(_ rootKey: String) -> [IncludeField] {
        return [.init(key: rootKey)]
    }

    public static func buildExpression(_ keys: [String]) -> [IncludeField] {
        return keys.map { IncludeField(key: $0) }
    }

    public static func buildExpression(_ keys: IncludeField) -> [IncludeField] {
        return [keys]
    }

    public static func buildExpression(_ keys: [IncludeField]) -> [IncludeField] {
        return keys
    }

    // MARK: Key + queries support

    public static func buildExpression(_ relationship: ToOne<IncludeCodingKey>) -> [IncludeField] {
        return [relationship.field]
    }

    public static func buildExpression(_ relationships: [ToOne<IncludeCodingKey>]) -> [IncludeField] {
        return relationships.map(\.field)
    }

    public static func buildExpression(_ relationship: ToMany<IncludeCodingKey>) -> [IncludeField] {
        return [relationship.field]
    }

    public static func buildExpression(_ relationships: [ToMany<IncludeCodingKey>]) -> [IncludeField] {
        return relationships.map(\.field)
    }

    public static func buildExpression(_ relationship: Nested<IncludeCodingKey>) -> [IncludeField] {
        return relationship.fields
    }

    public static func buildExpression(_ relationship: [Nested<IncludeCodingKey>]) -> [IncludeField] {
        return relationship.flatMap(\.fields)
    }

    // MARK: Either support

    public static func buildEither(first fields: [IncludeField]) -> [IncludeField] {
        return fields
    }

    public static func buildEither(second fields: [IncludeField]) -> [IncludeField] {
        return fields
    }

    // MARK: Optional support

    public static func buildOptional(_ fields: [IncludeField]?) -> [IncludeField] {
        return fields ?? []
    }

    // MARK: Array support

    static func buildArray(_ fields: [[IncludeField]]) -> [IncludeField] {
        return fields.flatMap { $0 }
    }
}

// MARK: - Supported types

public struct ToOne<IncludeCodingKey: IncludeKey> {

    public let field: IncludeField

    public init(_ codingKey: IncludeCodingKey, queries: [FieldQueryItem] = []) {
        self.field = .init(key: codingKey.includeKey, queryItems: queries)
    }
}

public struct ToMany<IncludeCodingKey: IncludeKey> {

    public let field: IncludeField

    public init(_ codingKey: IncludeCodingKey, queries: [FieldQueryItem] = []) {
        self.field = .init(key: codingKey.toMany.includeKey, queryItems: queries)
    }
}

public struct Nested<IncludeCodingKey: IncludeKey> {

    public let fields: [IncludeField]

    public init<T: IncludableType>(
        _ type: T.Type,
        including includeType: T.IncludeType,
        at key: IncludeCodingKey,
        toMany: Bool = false,
        queries: [FieldQueryItem] = []
    ) {
        let rootKey = toMany ? key.toMany : key
        let nestedFields = includeType.prepareIncludes().map { $0.nested(at: rootKey.includeKey) }
        self.fields = [.init(key: rootKey.includeKey, queryItems: queries)] + nestedFields
    }
}
