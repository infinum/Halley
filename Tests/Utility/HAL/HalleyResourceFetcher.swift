import Foundation
import Halley
import Combine

public class HalleyResourceFetcher {

    let resourceManager: ResourceManager
    let baseUrl: String
    let includes: [String]
    let onCreation: () -> Void

    init(
        fromJson jsonName: String,
        bundle: Bundle = Bundle.module,
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
        self.resourceManager = ResourceManager(requester: requester)
        self.baseUrl = baseUrl
        self.includes = includes
        self.onCreation = onCreation
    }

    convenience init<Item: IncludeableType>(
        fromJson jsonName: String,
        bundle: Bundle = Bundle.module,
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

public extension HalleyResourceFetcher {

    func resource<T>(ofType type: T.Type) throws -> AnyPublisher<T, Error> where T: Decodable {
        return resourceManager.request(HalleyRequest<T>(onURL: baseUrl, includes: includes))
    }

    func resourcePage<T>(ofType type: T.Type) throws -> AnyPublisher<PaginationPage<T>, Error> where T: Decodable {
        return resourceManager.requestPage(HalleyRequest<T>(onURL: baseUrl, includes: includes))
    }

    func resourceCollection<T>(ofType type: T.Type) throws -> AnyPublisher<[T], Error> where T: Decodable {
        return resourceManager.requestCollection(HalleyRequest<T>(onURL: baseUrl, includes: includes))
    }
}
