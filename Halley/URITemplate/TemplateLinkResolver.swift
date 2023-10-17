import Foundation

public protocol TemplateHandler {
    func resolveTemplate(for link: Link) throws -> URL
}

public class TemplateLinkResolver: LinkResolver {
    let includeParameters: [String: [URLQueryItem]]
    let templateHandler: TemplateHandler

    public init(
        parameters: [String: [URLQueryItem]],
        templateHandler: TemplateHandler = DefaultTemplateHandler.shared
    ) {
        self.includeParameters = parameters
        self.templateHandler = templateHandler
    }

    public func resolveLink(_ link: Link, relationshipPath: String?) throws -> URL {
        var urlComponent = try URLComponents(
            url: try templateHandler.resolveTemplate(for: link),
            resolvingAgainstBaseURL: false
        ) ?? throwError(HalleyKit.Error.cantResolveURLFromLink(link: link))
        guard let parent = relationshipPath else { return try urlComponent.asURL() }
        let parameters = includeParameters[parent] ?? []
        // Avoid setting query items if there are no parameters to set
        // This will avoid an issue where empty array for `queryItems` will result
        // in dangling `?` in `url`
        if !parameters.isEmpty {
            // We merge same name query parameters and separate the value with `,`
            // We sort query parameters alphabetically by name and value in ascending order
            // This guarantees a consistent order for query parameters
            let queries = (urlComponent.queryItems ?? []) + parameters
            var dictionary = [String: String]()
            for query in queries {
                let value = [dictionary[query.name], query.value].compactMap{ $0 }
                dictionary[query.name] = value.sorted().joined(separator: ",")
            }
            urlComponent.queryItems = dictionary.map(URLQueryItem.init).sorted { $0.name < $1.name }
        }
        return try urlComponent.asURL()
    }
}
