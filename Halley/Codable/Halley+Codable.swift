import Foundation

public protocol HalleyCodable: Codable {
    var _links: Links? { get }
}

public extension HalleyCodable {

    @inlinable
    func links(for key: String) -> [Link]? {
        return _links?.links(for: key)
    }

    @inlinable
    func link(for key: String) -> Link? {
        return _links?.link(for: key)
    }

    @inlinable
    func href(for key: String) -> String? {
        return _links?.href(for: key)
    }

    @inlinable
    func isTemplated(for key: String) -> Bool? {
        return _links?.isTemplated(for: key)
    }

    @inlinable
    func asURL(for key: String, with variables: [String: Any]) throws -> URL? {
        return try _links?.asURL(for: key, with: variables)
    }

    @inlinable
    func asURL(for key: String, with queryItems: [URLQueryItem]) throws -> URL? {
        return try _links?.asURL(for: key, with: queryItems)
    }
}
