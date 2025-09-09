import Foundation

public struct Link: Sendable, Codable {
    public let href: String
    public let templated: Bool?
    public let type: String?
    public let deprecation: String?
    public let name: String?
    public let profile: String?
    public let title: String?
    public let hreflang: String?


    public enum CodingKeys: String, CodingKey {
        case href
        case templated
        case type
        case deprecation
        case name
        case profile
        case title
        case hreflang
    }

    public init(
        href: String,
        templated: Bool? = nil,
        type: String? = nil,
        deprecation: String? = nil,
        name: String? = nil,
        profile: String? = nil,
        title: String? = nil,
        hreflang: String? = nil
    ) {
        self.href = href
        self.templated = templated
        self.type = type
        self.deprecation = deprecation
        self.name = name
        self.profile = profile
        self.title = title
        self.hreflang = hreflang
    }
}
