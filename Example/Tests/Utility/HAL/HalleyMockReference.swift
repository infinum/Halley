import Foundation
import Halley

struct HalleyMockReference {
    let jsonName: String
    let bundle: Bundle

    init(
        jsonName: String,
        bundle: Bundle = Bundle(for: JSONParsingUtilities.self)
    ) {
        self.jsonName = jsonName
        self.bundle = bundle
    }

    func load() throws -> Data {
        let path = try bundle
            .url(forResource: jsonName, withExtension: "json")
            .orThrow(HalleyTestError.conditionFailed("File \(jsonName).json not found in \(bundle)."))
        return try Data(contentsOf: path)
    }
}
