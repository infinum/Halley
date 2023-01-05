import Foundation

public protocol HalleyURLConvertible: CustomStringConvertible {
    func asHalleyURL() throws -> URL
}

extension String: HalleyURLConvertible {

    public func asHalleyURL() throws -> URL {
        try URL(string: self) ?? throwHalleyError(.cantResolveURLFromString(string: self))
    }
}

extension URL: HalleyURLConvertible {
    public func asHalleyURL() throws -> URL { self }
}

extension URLComponents: HalleyURLConvertible {

    public func asHalleyURL() throws -> URL {
        try url ?? throwHalleyError(.cantResolveURLFromString(string: string))
    }
}
