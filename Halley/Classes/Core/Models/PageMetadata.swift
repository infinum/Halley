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

    static func fromParameters(_ parameters: Parameters) -> PageMetadata? {
        return (try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed))
            .flatMap { try? JSONDecoder().decode(PageMetadata.self, from: $0) }
    }
}
