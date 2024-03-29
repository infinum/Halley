import Foundation
import Combine

public struct HalleyRequest<Item: Decodable> {
    public let urlConvertible: URLConvertible
    public let includes: [String]
    public let linkResolver: LinkResolver
    public let decoder: JSONDecoder
    public let options: HalleyKit.Options

    public init(
        url: URLConvertible,
        includes: [String],
        linkResolver: LinkResolver,
        decoder: JSONDecoder,
        options: HalleyKit.Options = .default
    ) {
        self.urlConvertible = url
        self.includes = includes
        self.linkResolver = linkResolver
        self.decoder = decoder
        self.options = options
    }

    public init(
        url: URLConvertible,
        includeType: Item.IncludeType?,
        queryItems: [URLQueryItem],
        decoder: JSONDecoder,
        options: HalleyKit.Options = .default
    ) where Item: HalleyCodable & IncludableType {
        let includeFields = includeType?.prepareIncludes() ?? []
        self.init(
            url: url,
            includes: includeFields.includeKeys(),
            linkResolver: includeFields.linkResolver(customTemplatedQueryItems: queryItems),
            decoder: decoder,
            options: options
        )
    }

    public func url() throws -> URL {
        try urlConvertible.asURL()
    }
}
