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
}
