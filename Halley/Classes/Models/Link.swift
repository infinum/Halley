import Foundation

public struct Link: Codable {
    public let href: String
    public let templated: Bool?

    enum CodingKeys: String, CodingKey {
        case href
        case templated
    }

    func resolvedUrl() throws -> URL {
        return try URL(string: href) ?? throwHalleyError(.cantResolveURLFromLink(link: self))
    }
}
