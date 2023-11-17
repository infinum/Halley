import Foundation
import Combine

public struct HalleyRequest<Item: Decodable> {
    public let urlConvertible: URLConvertible
    public let includes: [String]
    public let linkResolver: LinkResolver
    public let decoder: JSONDecoder

    public init(
        url: URLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decoder: JSONDecoder
    ) {
        self.urlConvertible = url
        self.includes = includes
        self.linkResolver = linkResolver
        self.decoder = decoder
    }

    public init(
        url: URLConvertible,
        includeType: Item.IncludeType?,
        queryItems: [URLQueryItem],
        decoder: JSONDecoder
    ) where Item: HalleyCodable & IncludableType {
        let includeFields = includeType?.prepareIncludes() ?? []
        self.init(
            url: url,
            includes: includeFields.includeKeys(),
            linkResolver: includeFields.linkResolver(customTemplatedQueryItems: queryItems),
            decoder: decoder
        )
    }

    public func url() throws -> URL {
        try urlConvertible.asURL()
    }
}
