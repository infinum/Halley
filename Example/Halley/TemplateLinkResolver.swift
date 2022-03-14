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

struct URITemplates {
    static let countryKey = "country"
    static let countriesKey = "countries"
    static let valuePer = "valuePer"
    static let unitSystem = "unitSystem"
    static let electricSystem = "electricSystem"
}

class URITemplateManager {

    private lazy var _uriTemplateHandler = DefaultTemplateHandler.shared

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
