import Foundation

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

    struct Response {
        let relationship: String
        let result: JSONResult
    }
}

