import Foundation
import Halley

struct Website: HalleyCodable {
    let _links: Links?

    let id: String
    let url: URL
}

struct Contact: HalleyCodable {
    let _links: Links?

    let id: String
    let name: String
    let contacts: [Contact]?
    let website: Website?

    enum CodingKeys: String, CodingKey, IncludeKey {
        case _links
        case id
        case name
        case contacts
        case website
    }
}

extension Contact: IncludeableType {

    enum IncludeType {
        case full
        case contacts
        case website
        case contactsOfContacts
        case contactsAndWebsiteOfContacts
    }
}

extension Contact.IncludeType: IncludeTypeInterface {
    typealias IncludeCodingKey = Contact.CodingKeys

    @IncludesBuilder<IncludeCodingKey>
    public func prepareIncludes() -> [IncludeField] {
        switch self {
        case .full:
            ToMany(.contacts)
            ToOne(.website)
        case .contacts:
            ToMany(.contacts)
        case .website:
            ToOne(.website)
        case .contactsOfContacts:
            Nested(Contact.self, including: .contacts, at: .contacts, toMany: true)
        case .contactsAndWebsiteOfContacts:
            Nested(Contact.self, including: .full, at: .contacts, toMany: true)
            ToOne(.website)
        }
    }
}
