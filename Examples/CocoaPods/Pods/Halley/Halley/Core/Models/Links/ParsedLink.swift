import Foundation

public enum ParsedLink {
    case object(Link)
    case array([Link])

    var isEmpty: Bool {
        switch self {
        case .object: false
        case .array(let links): links.isEmpty
        }
    }

    var asArray: [Link] {
        switch self {
        case .object(let link): [link]
        case .array(let links): links
        }
    }
}
