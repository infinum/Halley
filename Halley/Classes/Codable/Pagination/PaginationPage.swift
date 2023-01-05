import Foundation

public class PaginationPage<T: Codable>: Codable {

    public var itemCount: Int { resources?.count ?? 0 }

    public let resources: [T]?
    public let metadata: PageMetadata
    public let _links: PageLinks

    public enum CodingKeys: String, CodingKey {
        case resources = "item"
        case metadata = "page"
        case _links
    }

    public init(links: PageLinks, resources: [T]?, metadata: PageMetadata) {
        _links = links
        self.resources = resources
        self.metadata = metadata
    }

    public static func empty() -> PaginationPage {
        return PaginationPage(links: .empty(), resources: [], metadata: .empty())
    }

    public func mapResources<New>(
        _ transform: (T) -> New
    ) -> PaginationPage<New> {
        return .init(
            links: _links,
            resources: resources?.map(transform),
            metadata: metadata
        )
    }
}
