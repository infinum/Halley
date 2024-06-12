import Foundation

public struct Links: Codable {

    // MARK: - Public properties

    public typealias EmbeddedLinks = [String: [Link]]

    public static var empty = Links(relationships: [:])

    public let relationships: EmbeddedLinks
    // Similar to `relationships` but keeps the information whether the parsed link for
    // a relationship was an object or an array. This kind of an information is important
    // during the traversal - based on it we decide whether we should expect single resource
    // or a collection of resources.
    public let parsedLinks: [String: ParsedLink]
    public var selfLink: Link? { relationships[HalleyConsts.`self`]?.first }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        let parsedLinks = container
            .allKeys
            .map(\.stringValue)
            .compactMap(CustomCodingKeys.init)
            .reduce(into: [String: ParsedLink]()) { links, key in
                if let value = try? container.decode(Link.self, forKey: key) {
                    links[key.stringValue] = .object(value)
                } else if let value = try? container.decode([Link].self, forKey: key) {
                    links[key.stringValue] = .array(value)
                }
            }
        self.parsedLinks = parsedLinks
        self.relationships = parsedLinks.mapValues(\.asArray)
    }

    public init(parsedLinks: [String: ParsedLink]) {
        self.parsedLinks = parsedLinks
        self.relationships = parsedLinks.mapValues(\.asArray)
    }

    public init(relationships: EmbeddedLinks) {
        self.relationships = relationships
        // This was the default behaviour on versions 1.7.0 and below where parsing multiple links
        // for single relationship wasn't supported.
        self.parsedLinks = relationships.mapValues { .array($0) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        try parsedLinks.forEach { (key, parsedLink) in
            switch parsedLink {
            case .array(let links) where !links.isEmpty:
                try container.encode(links, forKey: .init(stringValue: key))
            case .object(let link):
                try container.encode(link, forKey: .init(stringValue: key))
            case .array:
                // Skip the encoding if there is no link for given relationship
                break
            }

        }
    }

    // MARK: - Helper

    private struct CustomCodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?

        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            return nil
        }
    }
}
