import Foundation

public class PageLinks: Codable {
    public let selfLink: Link
    public let first: Link?
    public let previous: Link?
    public let next: Link?
    public let last: Link?
    public let items: [Link]?

    public enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case previous = "prev"
        case items = "item"
        case first
        case next
        case last
    }

    public init(
        selfLink: Link,
        first: Link? = nil,
        previous: Link? = nil,
        next: Link? = nil,
        last: Link? = nil,
        items: [Link]? = nil
    ) {
        self.selfLink = selfLink
        self.first = first
        self.previous = previous
        self.next = next
        self.last = last
        self.items = items
    }

    public static func empty() -> PageLinks {
        return .init(selfLink: .init(href: "", templated: nil))
    }
}
