import Foundation
import Combine

// MARK: - Codable

public extension ResourceManager {

    func request<Item>(_ input: HalleyRequest<Item>) async throws -> Item {
        let jsonResponse = await resource(
            from: try input.url(),
            includes: input.includes,
            linkResolver: input.linkResolver
        )
        return try Self.decode(result: jsonResponse, type: Item.self, decoder: input.decoder)
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) async throws -> [Item] {
        let jsonResponse = await resourceCollection(
            from: try input.url(),
            includes: input.includes,
            linkResolver: input.linkResolver
        )
        return try Self.decode(result: jsonResponse, type: [Item].self, decoder: input.decoder)
    }

    func requestPage<Item>(_ input: HalleyRequest<Item>) async throws -> PaginationPage<Item> {
        let jsonResponse = await resourceCollectionWithMetadata(
            from: try input.url(),
            includes: input.includes,
            linkResolver: input.linkResolver
        )
        return try Self.decode(result: jsonResponse, type: PaginationPage<Item>.self, decoder: input.decoder)
    }
}

// MARK: - Private helpers

private extension ResourceManager {

    static func decode<T, U: Decodable>(result: Result<T, Error>, type: U.Type, decoder: JSONDecoder) throws -> U {
        switch result {
        case .success(let jsonObject):
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.fragmentsAllowed])
            return try decoder.decode(U.self, from: jsonData)
        case .failure(let failure):
            throw failure
        }
    }
}
