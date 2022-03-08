import Foundation

public protocol LinkResolver {
    func resolveLink(_ link: Link, relationshipPath: String?) throws -> URL
}

public class URLLinkResolver: LinkResolver {
    public init() { }
    public func resolveLink(_ link: Link, relationshipPath: String?) throws -> URL {
        // Relationship path is not used in the simple URL resolver
        return try URL(string: link.href) ?? throwHalleyError(.cantResolveURLFromLink(link: link))
    }
}
