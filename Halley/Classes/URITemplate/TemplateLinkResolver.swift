import Foundation
import URITemplate

public protocol TemplateHandler {
    func resolveTemplate(for link: Link) -> String
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
        let resolvedString = templateHandler.resolveTemplate(for: link)

        var urlComponent = try URLComponents(string: resolvedString) ?? throwError(HalleyKit.Error.cantResolveURLFromLink(link: link))
        guard let parent = relationshipPath else { return try urlComponent.asURL() }
        let parameters = includeParameters[parent] ?? []
        // Avoid setting query items if there are no parameters to set
        // This will avoid an issue where empty array for `queryItems` will result
        // in dangling `?` in `url`
        if !parameters.isEmpty {
            urlComponent.queryItems = (urlComponent.queryItems ?? []) + parameters
        }
        return try urlComponent.asURL()
    }
}

extension URLComponents {

    func asURL() throws -> URL {
        guard let url = url else { throw HalleyKit.Error.cantResolveURLFromString(string: string)}
        return url
    }
}
