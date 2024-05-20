import Foundation

public class PaginationPage<T: Codable>: Codable {

    public var itemCount: Int { resources?.count ?? 0 }

    public let resources: [T]?
    public let metadata: PageMetadata
    public let _links: Links?
    public let _pageLinks: PageLinks

    public enum CodingKeys: String, CodingKey {
        case resources = "item"
        case metadata = "page"
        case _links
    }

    public required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<PaginationPage<T>.CodingKeys> = try decoder.container(keyedBy: PaginationPage<T>.CodingKeys.self)
        self.resources = try container.decodeIfPresent([T].self, forKey: PaginationPage<T>.CodingKeys.resources)
        self.metadata = try container.decode(PageMetadata.self, forKey: PaginationPage<T>.CodingKeys.metadata)
        self._links = try container.decode(Links.self, forKey: PaginationPage<T>.CodingKeys._links)
        self._pageLinks = try container.decode(PageLinks.self, forKey: PaginationPage<T>.CodingKeys._links)
    }

    public init(pageLinks: PageLinks, resources: [T]?, metadata: PageMetadata, links: Links?) {
        _pageLinks = pageLinks
        self.resources = resources
        self.metadata = metadata
        _links = links
    }

    public static func empty() -> PaginationPage {
        return PaginationPage(pageLinks: .empty(), resources: [], metadata: .empty(), links: nil)
    }

    public func mapResources<New>(
        _ transform: (T) -> New
    ) -> PaginationPage<New> {
        return .init(
            pageLinks: _pageLinks,
            resources: resources?.map(transform),
            metadata: metadata,
            links: _links
        )
    }
}
