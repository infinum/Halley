import Foundation

// MARK: - Expand

public extension Link {

    /// Expands current link, removing templates if present
    /// - Parameter queryItems: query items, default empty array
    /// - Returns: Expanded link
    func expand() -> String {
        return expand(with: [:])
    }

    /// If link is templated it expands it with given query items, otherwise it just returns current href
    /// - Parameter queryItems: query items, default empty array
    /// - Returns: Expanded link
    func expand(with queryItems: [URLQueryItem] = []) -> String {
        guard templated == true else { return href }
        let varibles = queryItems.reduce(into: [String: Any]()) {
            $0[$1.name] = $1.value
        }
        return expand(with: varibles)
    }

    /// If link is templated it expands it with given query items, otherwise it just returns current href
    /// - Parameter variables: key-value variables, default is empty array
    /// - Returns: Expanded link
    func expand(with variables: [String: Any] = [:]) -> String {
        guard templated == true else { return href }
        let template = URITemplate(template: href)
        return template.expand(variables)
    }
}

public extension Link {

    /// Expands current link to URL, removing templates if present
    /// - Parameter queryItems: query items, default empty array
    /// - Returns: Expanded link URL
    func asURL() throws -> URL {
        return try expand().asURL()
    }

    /// If link is templated it expands it with given query items, otherwise it just returns current href
    /// - Parameter queryItems: query items, default empty array
    /// - Returns: Expanded link URL
    func asURL(with queryItems: [URLQueryItem] = []) throws -> URL {
        return try expand(with: queryItems).asURL()
    }

    /// If link is templated it expands it with given query items, otherwise it just returns current URL
    /// - Parameter variables: key-value variables, default is empty array
    /// - Returns: Expanded link URL
    func asURL(with variables: [String: Any] = [:]) throws -> URL {
        return try expand(with: variables).asURL()
    }
}

public extension Halley.Links {

    @inlinable
    func asURL(for key: String, with variables: [String: Any]) throws -> URL? {
        return try relationships[key]?.first?.asURL(with: variables)
    }

    @inlinable
    func asURL(for key: String, with queryItems: [URLQueryItem]) throws -> URL? {
        return try relationships[key]?.first?.asURL(with: queryItems)
    }
}
