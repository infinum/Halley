import Foundation

public struct PageMetadata: Codable {
    public let size: Int
    public let totalElements: Int
    public let totalPages: Int
    public let currentPage: Int

    enum CodingKeys: String, CodingKey {
        case size
        case totalElements
        case totalPages
        case currentPage = "number"
    }

    public init(size: Int, totalElements: Int, totalPages: Int, currentPage: Int) {
        self.size = size
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.currentPage = currentPage
    }

    public static func empty() -> PageMetadata {
        return PageMetadata(size: 0, totalElements: 0, totalPages: 0, currentPage: 0)
    }
}
