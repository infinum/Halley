import Foundation

class ResourceContainer {
    let parameters: Parameters
    let _links: Links?

    init(_ parameters: Parameters) {
        var _parameters = parameters
        _links = try? parameters.decode(Links.self, at: HalleyConsts.links)
        let _embedded = parameters[HalleyConsts.embedded] as? [String: Any]
        // Adds embedded resources to the result dictionary
        _embedded?.forEach({ _parameters[$0.key] = $0.value })
        _parameters.removeValue(forKey: HalleyConsts.embedded)
        self.parameters = _parameters
    }

    func hasEmbeddedRelationship(_ relationship: String) -> Bool {
        return parameters[relationship] != nil
    }
}

struct Includes {
    let values: [Include]
    /// Path of the relationship for given includes. This is `nil` for the initial include list
    let relationshipPath: String?

    func path(for relationship: String) -> String {
        guard let parent = relationshipPath else {
            return relationship
        }
        let separator = String(HalleyConsts.includeSeparator)
        return [parent, relationship].joined(separator: separator)
    }
}

/// Model for handling includes
/// To specify if a include is `toMany`, the key must be inside `[]` (eg. `[images]`)
struct Include {
    let type: Relationship.ParsingType
    let key: String
    /// Includes the `[]` in the string
    let rawKey: String
    let value: [String]?

    init(key: String, values: [String]?) {
        let isArray = key.hasPrefix("[") && key.hasSuffix("]")
        type = isArray ? .toMany : .toOne
        value = values
        self.rawKey = key
        self.key = key.trimmingCharacters(in: .init(charactersIn: "[]"))
    }
}

enum Relationship {

    enum ParsingType {
        case toOne
        case toMany
    }

    struct FetchOptions {
        let relationship: String
        let parsedLink: ParsedLink
        let includes: Includes
        let parsingType: Relationship.ParsingType
        let isEmbedded: Bool
    }
}

struct LinkResponse {
    let relationship: String
    let result: JSONResult
}
