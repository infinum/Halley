import Foundation

public struct IncludeField {
    public let key: String
    public let queryItems: [FieldQueryItem]

    public init(key: String, queryItems: [FieldQueryItem] = []) {
        self.key = key
        self.queryItems = queryItems
    }

    public func nested(at rootKey: String) -> IncludeField {
        let separator = String(HalleyConsts.includeSeparator)
        let key = [rootKey, key].joined(separator: separator)
        return .init(key: key, queryItems: queryItems)
    }
}


public extension Array where Element == IncludeField {

    func includeKeys() -> [String] {
        return map(\.key)
    }

    func includeQueryItems() -> [String: [FieldQueryItem]] {
        let keyedFields = Dictionary(grouping: self) { $0.key }
        return keyedFields
            .mapValues { $0.flatMap(\.queryItems) }
            .filter { !$0.value.isEmpty } // Filter out fields with no query items
    }

    func linkResolver(customTemplatedQueryItems: [URLQueryItem]) -> LinkResolver {
        let parameters = includeQueryItems().mapValues { $0.map(\.asQueryItem) }
        return TemplateLinkResolver(
            parameters: parameters,
            templateHandler: OverridingTemplateHandler(queryItems: customTemplatedQueryItems)
        )
    }
}
