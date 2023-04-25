import Foundation
import RxSwift
import Halley

class JSONParsingUtilities {

    private init() {
        // Static methods
    }

    static var defaultError: HalleyTestError {
        return .mockError
    }
}

// MARK: - Resource

extension JSONParsingUtilities {

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

    static func observableResource<T>(
        fromJson jsonName: String,
        shouldReturnError: Bool = false,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) -> Single<T> where T: Decodable {
        guard !shouldReturnError else {
            return .error(JSONParsingUtilities.defaultError)
        }
        do {
            let data = try JSONFixtureWithName(jsonName, bundle: bundle)
            let resource: T = try decode(data: data, type: T.self)
            return .just(resource)
        } catch {
            return .error(error)
        }
    }
}

// MARK: - Collection

extension JSONParsingUtilities {

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

    static func observableResourceArray<T>(
        fromJson jsonName: String,
        shouldReturnError: Bool = false,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) -> Single<[T]> where T: Decodable {
        guard !shouldReturnError else {
            return .error(JSONParsingUtilities.defaultError)
        }
        do {
            let data = try JSONFixtureWithName(jsonName, bundle: bundle)
            let resourceArray = try decode(data: data, type: [T].self)
            return .just(resourceArray)
        } catch {
            return .error(error)
        }
    }
}

// MARK: - Page

extension JSONParsingUtilities {

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

    static func observableResourcePage<T>(
        fromJson jsonName: String,
        shouldReturnError: Bool = false,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) -> Single<Halley.PaginationPage<T>> where T: Decodable {
        guard !shouldReturnError else {
            return .error(JSONParsingUtilities.defaultError)
        }
        do {
            let data = try JSONFixtureWithName(jsonName, bundle: bundle)
            let page = try decode(data: data, type: Halley.PaginationPage<T>.self)
            return .just(page)
        } catch {
            return .error(error)
        }
    }
}

// MARK: - Helpers

extension JSONParsingUtilities {

    static func JSONFixtureWithName(
        _ name: String,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) throws -> Data {
        let path = try bundle
            .url(forResource: name, withExtension: "json")
            .orThrow(HalleyTestError.conditionFailed("File \(name).json not found in \(bundle)."))
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
