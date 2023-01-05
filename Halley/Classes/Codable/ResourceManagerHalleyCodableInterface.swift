import Foundation
import Combine

public protocol ResourceManagerHalleyCodableInterface {

    func request<Item: HalleyCodable & IncludeableType>(
        _ type: Item.Type,
        onURL urlConvertible: HalleyURLConvertible,
        includeType: Item.IncludeType?,
        customTemplatedQueryItems queryItems: [URLQueryItem],
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<Item, Error>

    func requestCollection<Item: HalleyCodable & IncludeableType>(
        _ type: Item.Type,
        onURL urlConvertible: HalleyURLConvertible,
        includeType: Item.IncludeType?,
        customTemplatedQueryItems queryItems: [URLQueryItem],
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<[Item], Error>

    func requestPage<Item: HalleyCodable & IncludeableType>(
        _ type: Item.Type,
        onURL urlConvertible: HalleyURLConvertible,
        includeType: Item.IncludeType?,
        customTemplatedQueryItems queryItems: [URLQueryItem],
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<PaginationPage<Item>, Error>
}
