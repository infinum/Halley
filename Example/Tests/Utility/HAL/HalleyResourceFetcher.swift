import Foundation
import Halley

class HalleyResourceFetcher {

    let apiService: ResourceManager
    let baseUrl: String
    let includes: [String]
    let onCreation: () -> Void

    init(
        fromJson jsonName: String,
        bundle: Bundle = Bundle(for: HalleyResourceFetcher.self),
        includes: [String] = [],
        registeredMocks: HalleyMockReferences = .shared,
        onCreation: @escaping () -> Void = { }
    ) {
        // Requester logic is invoked for every URL, even for root one
        // so give any name to it, just to connect it with base JSON resource
        let baseUrl = "https://halley.com/mocks/\(jsonName)"
        let baseMock = HalleyMockReference(jsonName: jsonName, bundle: bundle)
        var mocks = registeredMocks
        mocks[baseUrl] = baseMock
        let requester = HalleyMockRequester(registeredMocks: mocks)
        self.apiService = .init(requester: requester)
        self.baseUrl = baseUrl
        self.includes = includes
        self.onCreation = onCreation
    }

    convenience init<Item: IncludeableType>(
        fromJson jsonName: String,
        bundle: Bundle = Bundle(for: HalleyResourceFetcher.self),
        for: Item.Type,
        includeType: Item.IncludeType? = nil,
        registeredMocks: HalleyMockReferences = .shared,
        onCreation: @escaping () -> Void = { }
    ) {
        let includeFields = includeType?.prepareIncludes() ?? []
        self.init(
            fromJson: jsonName,
            bundle: bundle,
            includes: includeFields.includeKeys(),
            registeredMocks: registeredMocks,
            onCreation: onCreation
        )
    }
}
//
//extension HalleyResourceFetcher {
//
//    func resource<T>(
//        ofType type: T.Type,
//        shouldReturnError: Bool = false
//    ) throws -> T where T: Decodable {
//        guard !shouldReturnError else {
//            throw JSONParsingUtilities.defaultError
//        }
//        return try apiService
//            .request(HalleyRequest<T>(onURL: baseUrl, includes: includes))
//            .do(onSubscribe: {
//                // Capture self here in order to prevent from deiniting
//                self.onCreation()
//            })
//            .toBlockingElement()
//    }
//
//    func rxResource<T>(
//        ofType type: T.Type,
//        shouldReturnError: Bool = false
//    ) -> Single<T> where T: Decodable {
//        // All Rx calls should be blocked since Halley internally uses OperationQueue
//        // which can result in hanging tests
//        do {
//            let resource = try resource(ofType: type, shouldReturnError: shouldReturnError)
//            return .just(resource)
//        } catch {
//            return .error(error)
//        }
//    }
//}
//
//extension HalleyResourceFetcher {
//
//    func resourcePage<T>(
//        ofType type: T.Type,
//        shouldReturnError: Bool = false
//    ) throws -> DANetworking.PaginationPage<T> where T: Codable {
//        guard !shouldReturnError else {
//            throw JSONParsingUtilities.defaultError
//        }
//        return try apiService
//            .requestPage(HalleyRequest<T>(onURL: baseUrl, includes: includes))
//            .do(onSubscribe: {
//                // Capture self here in order to prevent from deiniting
//                self.onCreation()
//            })
//            .toBlockingElement()
//    }
//
//    func rxResourcePage<T>(
//        ofType type: T.Type,
//        shouldReturnError: Bool = false
//    ) -> Single<PaginationPage<T>> where T: Codable {
//        // All Rx calls should be blocked since Halley internally uses OperationQueue
//        // which can result in hanging tests
//        do {
//            let page = try resourcePage(ofType: type, shouldReturnError: shouldReturnError)
//            return .just(page)
//        } catch {
//            return .error(error)
//        }
//    }
//}
//
//extension HalleyResourceFetcher {
//
//    func resourceCollection<T>(
//        ofType type: T.Type,
//        shouldReturnError: Bool = false
//    ) throws -> [T] where T: Codable {
//        guard !shouldReturnError else {
//            throw JSONParsingUtilities.defaultError
//        }
//        return try apiService
//            .requestCollection(HalleyRequest<T>(onURL: baseUrl, includes: includes))
//            .do(onSubscribe: {
//                // Capture self here in order to prevent from deiniting
//                self.onCreation()
//            })
//            .toBlockingElement()
//    }
//
//    func rxResourceCollection<T>(
//        ofType type: T.Type,
//        shouldReturnError: Bool = false
//    ) -> Single<[T]> where T: Codable {
//        // All Rx calls should be blocked since Halley internally uses OperationQueue
//        // which can result in hanging tests
//        do {
//            let collection = try resourceCollection(ofType: type, shouldReturnError: shouldReturnError)
//            return .just(collection)
//        } catch {
//            return .error(error)
//        }
//    }
//}
//
//extension Single {
//
//    func toBlockingElement() throws -> Element {
//        return try asObservable()
//            .toBlocking()
//            .first()
//            .orThrow(.conditionFailed("Timeout error"))
//    }
//}
