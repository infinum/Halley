import Foundation
import Halley

public struct HalleyMockReference {
    public let jsonName: String
    public let bundle: Bundle

    public init(
        jsonName: String,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) {
        self.jsonName = jsonName
        self.bundle = bundle
    }

    func load() throws -> Data {
        let path = try bundle
            .url(forResource: jsonName, withExtension: "json")
            .orThrow(HalleyTestsError.conditionFailed("File \(jsonName).json not found in \(bundle)."))
        return try Data(contentsOf: path)
    }
}

extension Optional {

    func orThrow<E: Error>(_ errorClosure: @autoclosure () -> E) throws -> Wrapped {
        guard let value = self else {
            throw errorClosure()
        }
        return value
    }
}
