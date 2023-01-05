import Foundation
import Combine

// MARK: - Codable

public extension ResourceManager {

    func request<Item: Decodable>(
        _ type: Item.Type,
        onURL urlConvertible: URLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<Item, Error> {
        guard let url = try? urlConvertible.asHalleyURL() else {
            return .error(.cantResolveURLFromString(string: urlConvertible.description))
        }
        return self
            .resource(from: url, includes: includes, linkResolver: linkResolver)
            .unwrapResult()
            .tryMap { try Self.decode(data: $0, type: type, decoder: decoder) }
            .eraseToAnyPublisher()
    }

    func requestCollection<Item: Decodable>(
        _ type: Item.Type,
        onURL urlConvertible: URLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<[Item], Error> {
        guard let url = try? urlConvertible.asHalleyURL() else {
            return .error(.cantResolveURLFromString(string: urlConvertible.description))
        }
        return self
            .resourceCollection(from: url, includes: includes, linkResolver: linkResolver)
            .unwrapResult()
            .tryMap { try Self.decode(data: $0, type: [Item].self, decoder: decoder) }
            .eraseToAnyPublisher()
    }

    func requestPage<Item: Decodable>(
        _ type: Item.Type,
        onURL urlConvertible: URLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<PaginationPage<Item>, Error> {
        guard let url = try? urlConvertible.asHalleyURL() else {
            return .error(.cantResolveURLFromString(string: urlConvertible.description))
        }
        return self
            .resourceCollectionWithMetadata(from: url, includes: includes, linkResolver: linkResolver)
            .unwrapResult()
            .tryMap { try Self.decode(data: $0, type: PaginationPage<Item>.self, decoder: decoder) }
            .eraseToAnyPublisher()
    }
}

// MARK: - HalleyCodable

public extension ResourceManager {

    func request<Item: HalleyCodable & IncludeableType>(
        _ type: Item.Type,
        onURL urlConvertible: URLConvertible,
        includeType: Item.IncludeType?,
        customTemplatedQueryItems queryItems: [URLQueryItem],
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<Item, Error> {
        let includeFields = includeType?.prepareIncludes() ?? []
        return request(
            type,
            onURL: urlConvertible,
            includes: includeFields.includeKeys(),
            linkResolver: includeFields.linkResolver(customTemplatedQueryItems: queryItems),
            decodedWith: decoder
        )
    }

    func requestCollection<Item: HalleyCodable & IncludeableType>(
        _ type: Item.Type,
        onURL urlConvertible: URLConvertible,
        includeType: Item.IncludeType? = nil,
        customTemplatedQueryItems queryItems: [URLQueryItem] = [],
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<[Item], Error> {
        let includeFields = includeType?.prepareIncludes() ?? []
        return requestCollection(
            type,
            onURL: urlConvertible,
            includes: includeFields.includeKeys(),
            linkResolver: includeFields.linkResolver(customTemplatedQueryItems: queryItems),
            decodedWith: decoder
        )
    }

    func requestPage<Item: HalleyCodable & IncludeableType>(
        _ type: Item.Type,
        onURL urlConvertible: URLConvertible,
        includeType: Item.IncludeType?,
        customTemplatedQueryItems queryItems: [URLQueryItem],
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<PaginationPage<Item>, Error> {
        let includeFields = includeType?.prepareIncludes() ?? []
        return requestPage(
            type,
            onURL: urlConvertible,
            includes: includeFields.includeKeys(),
            linkResolver: includeFields.linkResolver(customTemplatedQueryItems: queryItems),
            decodedWith: decoder
        )
    }
}

// MARK: - Private helpers

private extension ResourceManager {

    static func decode<T, U: Decodable>(data: T, type: U.Type, decoder: JSONDecoder) throws -> U {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
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
