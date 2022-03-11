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

    init(relationships: EmbeddedLinks) {
        self.relationships = relationships
    }

    // MARK: - Helper

    private struct CustomCodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            return nil
        }
    }
}
