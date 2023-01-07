import Foundation
import Combine

// MARK: - Codable

public extension ResourceManager {

    func request<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<Item, Error> {
        do {
            return self
                .resource(from: try input.url(), includes: input.includes, linkResolver: input.linkResolver)
                .unwrapResult()
                .tryMap { try Self.decode(data: $0, type: Item.self, decoder: input.decoder) }
                .eraseToAnyPublisher()
        } catch {
            return .error(error)
        }
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<[Item], Error> {
        do {
            return self
                .resourceCollection(from: try input.url(), includes: input.includes, linkResolver: input.linkResolver)
                .unwrapResult()
                .tryMap { try Self.decode(data: $0, type: [Item].self, decoder: input.decoder) }
                .eraseToAnyPublisher()
        } catch {
            return .error(error)
        }
    }

    func requestPage<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<PaginationPage<Item>, Error> {
        do {
            return self
                .resourceCollectionWithMetadata(from: try input.url(), includes: input.includes, linkResolver: input.linkResolver)
                .unwrapResult()
                .tryMap { try Self.decode(data: $0, type: PaginationPage<Item>.self, decoder: input.decoder) }
                .eraseToAnyPublisher()
        } catch {
            return .error(error)
        }
    }
}

// MARK: - Private helpers

private extension ResourceManager {

    static func decode<T, U: Decodable>(data: T, type: U.Type, decoder: JSONDecoder) throws -> U {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [.fragmentsAllowed])
        return try decoder.decode(U.self, from: jsonData)
    }
}

private extension Publisher {

    func unwrapResult<T>() -> AnyPublisher<T, Error> where Output == Result<T, Error> {
        tryMap { result in
            switch result {
            case .success(let data):
                return data
            case .failure(let error):
                throw error
            }
        }
        .eraseToAnyPublisher()
    }
}
