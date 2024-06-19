import Foundation

public class OverridingTemplateHandler: TemplateHandler {

    public let `default` = DefaultTemplateHandler.shared
    public let queryItems: [String: URLQueryItem]

    public init(queryItems: [URLQueryItem]) {
        self.queryItems = Dictionary(grouping: queryItems) { $0.name }.compactMapValues(\.first)
    }

    public func resolveTemplate(for link: Link) throws -> URL {
        let defaultValues = `default`.expandedValues.mapValues(Optional.init)
        let overrideValues = queryItems.mapValues(\.value)
        let newValues = defaultValues
            .merging(overrideValues) { (_, new) in new }
            .compactMapValues { $0 }
        return try link.asURL(with: newValues)
    }
}
