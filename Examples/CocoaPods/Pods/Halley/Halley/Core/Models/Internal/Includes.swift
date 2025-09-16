import Foundation

/// Model for handling includes
/// To specify if a include is `toMany`, the key must be inside `[]` (eg. `[images]`)
struct Include {
    let type: Relationship.ParsingType
    let key: String
    /// Includes the `[]` in the string
    let rawKey: String
    let value: [String]?

    init(key: String, values: [String]?) {
        let isArray = key.hasPrefix(HalleyConsts.ToMany.leading) && key.hasSuffix(HalleyConsts.ToMany.trailing)
        type = isArray ? .toMany : .toOne
        value = values
        self.rawKey = key
        self.key = key.trimmingCharacters(in: HalleyConsts.ToMany.characterSet)
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

