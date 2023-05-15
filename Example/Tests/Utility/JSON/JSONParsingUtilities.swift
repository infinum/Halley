import Foundation
import Halley

public enum HalleyTestsError: Error {
    case missingData
    case conditionFailed(String)
    case missingInfo(String)
    case weakSelf
    case unknown
}

public class JSONParsingUtilities {

    private init() {
        // Static methods
    }

    public static var defaultError: HalleyTestsError {
        return .unknown
    }
}

// MARK: - Resource

public extension JSONParsingUtilities {

    static func resource<T>(
        fromJson jsonName: String,
        shouldReturnError: Bool = false,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) throws -> T where T: Decodable {
        guard !shouldReturnError else {
            throw JSONParsingUtilities.defaultError
        }
        let data = try JSONFixtureWithName(jsonName, bundle: bundle)
        return try decode(data: data, type: T.self)
    }
}

// MARK: - Collection

public extension JSONParsingUtilities {

    static func resourceArray<T>(
        fromJson jsonName: String,
        shouldReturnError: Bool = false,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) throws -> [T] where T: Decodable {
        guard !shouldReturnError else {
            throw JSONParsingUtilities.defaultError
        }
        let data = try JSONFixtureWithName(jsonName, bundle: bundle)
        return try decode(data: data, type: [T].self)
    }
}

// MARK: - Page

public extension JSONParsingUtilities {

    static func page<T>(
        fromJson jsonName: String,
        shouldReturnError: Bool = false,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) throws -> Halley.PaginationPage<T> where T: Decodable {
        guard !shouldReturnError else {
            throw JSONParsingUtilities.defaultError
        }
        let data = try JSONFixtureWithName(jsonName, bundle: bundle)
        return try decode(data: data, type: Halley.PaginationPage<T>.self)
    }
}

// MARK: - Helpers

public extension JSONParsingUtilities {

    static func JSONFixtureWithName(
        _ name: String,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) throws -> Data {
        let path = try bundle
            .url(forResource: name, withExtension: "json")
            .orThrow(HalleyTestsError.conditionFailed("File \(name).json not found in \(bundle)."))
        let data = try Data(contentsOf: path)
        return data
    }

    static func decode<T: Decodable>(data: Data, type: T.Type, decoder: JSONDecoder = .init()) throws -> T {
        return try decoder.decode(T.self, from: data)
    }

    static func decode<T, U: Decodable>(json: T, type: U.Type, decoder: JSONDecoder = .init()) throws -> U {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try decoder.decode(U.self, from: jsonData)
    }
}

extension HalleyRequest {

    init(
        onURL url: URLConvertible,
        includes: [String] = [],
        linkResolver: LinkResolver = TemplateLinkResolver(parameters: [:]),
        decoder: JSONDecoder = .init()
    ) where Item: Decodable {
        self.init(
            url: url,
            includes: includes,
            linkResolver: linkResolver,
            decoder: decoder
        )
    }

    init(
        onURL url: URLConvertible,
        includeType: Item.IncludeType? = nil,
        queryItems: [URLQueryItem] = [],
        decoder: JSONDecoder = .init()
    ) where Item: HalleyCodable & IncludeableType {
        self.init(
            url: url,
            includeType: includeType,
            queryItems: queryItems,
            decoder: decoder
        )
    }
}
