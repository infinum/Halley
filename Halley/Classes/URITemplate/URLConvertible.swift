import Foundation

public protocol URLConvertible: CustomStringConvertible {
    func asHalleyURL() throws -> URL
}

extension String: URLConvertible {

    public func asHalleyURL() throws -> URL {
        try URL(string: self) ?? throwHalleyError(.cantResolveURLFromString(string: self))
    }
}

extension URL: URLConvertible {
    public func asHalleyURL() throws -> URL { self }
}

extension URLComponents: URLConvertible {

    public func asHalleyURL() throws -> URL {
        try url ?? throwHalleyError(.cantResolveURLFromString(string: string))
    }
}
