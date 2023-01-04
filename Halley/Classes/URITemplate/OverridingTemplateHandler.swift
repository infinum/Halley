import Foundation
import URITemplate

public class OverridingTemplateHandler: TemplateHandler {

    public let `default` = DefaultTemplateHandler.shared
    public let queryItems: [String: URLQueryItem]

    public init(queryItems: [URLQueryItem]) {
        self.queryItems = Dictionary(grouping: queryItems) { $0.name }.compactMapValues(\.first)
    }

    public func resolveTemplate(for link: Link) throws -> URL {
        let defaultValues = `default`.expandedValues
        let overrideValues = queryItems.compactMapValues(\.value)
        let newValues = defaultValues.merging(overrideValues) { (_, new) in new }
        return try link.asURL(with: newValues)
    }
}
