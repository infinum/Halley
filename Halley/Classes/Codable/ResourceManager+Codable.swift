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
        return try Self.decode(data: jsonResponse, type: Item.self, decoder: input.decoder)
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) async throws -> [Item] {
        let jsonResponse = await resourceCollection(
            from: try input.url(),
            includes: input.includes,
            linkResolver: input.linkResolver
        )
        return try Self.decode(data: jsonResponse, type: [Item].self, decoder: input.decoder)
    }

    func requestPage<Item>(_ input: HalleyRequest<Item>) async throws -> PaginationPage<Item> {
        let jsonResponse = await resourceCollectionWithMetadata(
            from: try input.url(),
            includes: input.includes,
            linkResolver: input.linkResolver
        )
        return try Self.decode(data: jsonResponse, type: PaginationPage<Item>.self, decoder: input.decoder)
    }
}

// MARK: Codable + Combine

public extension ResourceManager {

    func request<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<Item, Error> {
        let publisher = ThrowingTaskPublisher { [weak self] in
            guard let self else { throw HalleyKit.Error.deinited }
            return try await self.request(input)
        }
        return publisher.eraseToAnyPublisher()
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<[Item], Error> {
        let publisher = ThrowingTaskPublisher { [weak self] in
            guard let self else { throw HalleyKit.Error.deinited }
            return try await self.requestCollection(input)
        }
        return publisher.eraseToAnyPublisher()
    }

    func requestCollection<Item>(_ input: HalleyRequest<Item>) -> AnyPublisher<PaginationPage<Item>, Error> {
        let publisher = ThrowingTaskPublisher { [weak self] in
            guard let self else { throw HalleyKit.Error.deinited }
            return try await self.requestPage(input)
        }
        return publisher.eraseToAnyPublisher()
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


extension Future where Failure == Error {

    convenience init(asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
