import Foundation

public struct Links: Codable {

    public typealias EmbeddedLinks = [String: [Link]]

    public static var empty = Links(relationships: [:])

    public let relationships: EmbeddedLinks
    public var selfLink: Link? { relationships[HalleyConsts.`self`]?.first }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        relationships = container
            .allKeys
            .map(\.stringValue)
            .compactMap(CustomCodingKeys.init)
            .reduce(into: EmbeddedLinks()) { links, key in
                if let value = try? container.decode(Link.self, forKey: key) {
                    links[key.stringValue] = [value]
                } else if let value = try? container.decode([Link].self, forKey: key) {
                    links[key.stringValue] = value
                }
            }
    }

    public init(relationships: EmbeddedLinks) {
        self.relationships = relationships
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CustomCodingKeys.self)
        try relationships.forEach { (key, links) in
            if links.count == 1, let link = links.first {
                try container.encode(link, forKey: .init(stringValue: key))
            } else if !links.isEmpty {
                try container.encode(links, forKey: .init(stringValue: key))
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
