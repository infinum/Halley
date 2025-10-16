import Foundation

public struct PaginationPage<T: Codable>: Codable {

    public var itemCount: Int { resources?.count ?? 0 }

    public let resources: [T]?
    public let metadata: PageMetadata
    public let _links: Links?

    public var firstPage: Link? { _links?.link(for: "first") }
    public var lastPage: Link? { _links?.link(for: "last") }
    public var nextPage: Link? { _links?.link(for: "next") }
    public var previousPage: Link? { _links?.link(for: "prev") }
    public var items: [Link]? { _links?.links(for: "item") }

    public enum CodingKeys: String, CodingKey {
        case resources = "item"
        case metadata = "page"
        case _links
    }

    public init(links: Links?, resources: [T]?, metadata: PageMetadata) {
        _links = links
        self.resources = resources
        self.metadata = metadata
    }

    public static func empty() -> PaginationPage {
        return PaginationPage(links: nil, resources: [], metadata: .empty())
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

extension PaginationPage: Sendable where T: Sendable {}
