import Foundation
import Combine

public protocol ResourceManagerCodableInterface {

    func request<Item: Decodable>(
        _ type: Item.Type,
        onURL urlConvertible: HalleyURLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<Item, Error>

    func requestCollection<Item: Decodable>(
        _ type: Item.Type,
        onURL urlConvertible: HalleyURLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<[Item], Error>

    func requestPage<Item: Decodable>(
        _ type: Item.Type,
        onURL urlConvertible: HalleyURLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decodedWith decoder: JSONDecoder
    ) -> AnyPublisher<PaginationPage<Item>, Error>
}
