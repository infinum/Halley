//
//  TemplateLinkResolver.swift
//  Halley_Example
//
//  Created by Zoran Turk on 25.02.2022..
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Halley
import URITemplate

// MARK: - Link Resolver Example -

class TemplateLinkResolver: LinkResolver {
    let templateManager = URITemplateHandler.shared

    func resolveLink(_ link: Link) throws -> URL {
        let resolvedString = templateManager.url(for: link)
        return try URL(string: resolvedString) ?? throwError(HalleyKit.Error.cantResolveURLFromLink(link: link))
    }
}

struct URITemplates {
    static let countryKey = "country"
    static let countriesKey = "countries"
    static let valuePer = "valuePer"
    static let unitSystem = "unitSystem"
    static let electricSystem = "electricSystem"
}

class URITemplateManager {

    private lazy var _uriTemplateHandler = URITemplateHandler.shared

    func setupTemplates() {
        _uriTemplateHandler.updateTamplate(for: URITemplates.countryKey, value: {
            return "DE"
        })
        _uriTemplateHandler.updateTamplate(for: URITemplates.countriesKey, value: {
            return "DE"
        })
        _uriTemplateHandler.updateTamplate(for: URITemplates.unitSystem, value: {
            return "METRIC"
        })
        _uriTemplateHandler.updateTamplate(for: URITemplates.electricSystem, value: {
            return "220V"
        })
    }
}

class URITemplateHandler {

    static let shared = URITemplateHandler()

    private var templateValues: [String: () -> String?] = [:]

    private init() {
        // Singleton pattern
    }

    func url(for link: Link) -> String {
        guard link.templated == true else { return link.href }

        var expandValues = [String: String]()
        for item in templateValues {
            if let value = item.value() {
                expandValues.updateValue(value, forKey: item.key)
            }
        }

        let template = URITemplate(template: link.href)
        return template.expand(expandValues)
    }

    func updateTamplate(for key: String, value: @escaping () -> String?) {
        templateValues.updateValue(value, forKey: key)
    }

    func removeTemplate(for key: String) {
        templateValues.removeValue(forKey: key)
    }
}

func throwError<T>(_ error: Error) throws -> T {
    throw error
}
