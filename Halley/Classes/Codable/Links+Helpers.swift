import Foundation

public extension Halley.Links {

    @inlinable
    func links(for key: String) -> [Link]? {
        return relationships[key]
    }

    @inlinable
    func link(for key: String) -> Link? {
        return relationships[key]?.first
    }

    @inlinable
    func href(for key: String) -> String? {
        return relationships[key]?.first?.href
    }

    @inlinable
    func isTemplated(for key: String) -> Bool? {
        return relationships[key]?.first?.templated
    }

    @inlinable
    func asURL(for key: String, with variables: [String: Any]) throws -> URL? {
        return try relationships[key]?.first?.asURL(with: variables)
    }

    @inlinable
    func asURL(for key: String, with queryItems: [URLQueryItem]) throws -> URL? {
        return try relationships[key]?.first?.asURL(with: queryItems)
    }
}
