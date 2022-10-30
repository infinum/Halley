import Foundation

public struct Link: Codable {
    public let href: String
    public let templated: Bool?

    enum CodingKeys: String, CodingKey {
        case href
        case templated
    }

    public init(href: String, templated: Bool?) {
        self.href = href
        self.templated = templated
    }
}
