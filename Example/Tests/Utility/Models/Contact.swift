//
//  Contact.swift
//  Halley_Example
//
//  Created by Filip Gulan on 11.05.2023..
//  Copyright © 2023 CocoaPods. All rights reserved.
//

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
        }
    }
}
