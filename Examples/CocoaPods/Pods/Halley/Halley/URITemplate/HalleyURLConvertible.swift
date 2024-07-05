import Foundation

public protocol URLConvertible: CustomStringConvertible {
    func asURL() throws -> URL
}

extension String: URLConvertible {

    public func asURL() throws -> URL {
        try URL(string: self) ?? throwHalleyError(.cantResolveURLFromString(string: self))
    }
}

extension URL: URLConvertible {
    public func asURL() throws -> URL { self }
}

extension URLComponents: URLConvertible {

    public func asURL() throws -> URL {
        try url ?? throwHalleyError(.cantResolveURLFromString(string: string))
    }
}
