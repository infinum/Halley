//
//  TemplateLinkResolver.swift
//  Halley_Example
//
//  Created by Zoran Turk on 25.02.2022..
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import URITemplate

public protocol TemplateHandler {
    func resolveTemplate(for link: Link) -> String
}

public class TemplateLinkResolver: LinkResolver {
    let includeParameters: [String: [URLQueryItem]]
    let templateHandler: TemplateHandler

    public init(
        parameters: [String: [URLQueryItem]],
        templateHandler: TemplateHandler = DefaultTemplateHandler.shared
    ) {
        self.includeParameters = parameters
        self.templateHandler = templateHandler
    }

    public func resolveLink(_ link: Link, relationshipPath: String?) throws -> URL {
        let resolvedString = templateHandler.resolveTemplate(for: link)

        var urlComponent = try URLComponents(string: resolvedString) ?? throwError(HalleyKit.Error.cantResolveURLFromLink(link: link))
        guard let parent = relationshipPath else { return try urlComponent.asURL() }
        let parameters = includeParameters[parent] ?? []
        // Avoid setting query items if there are no parameters to set
        // This will avoid an issue where empty array for `queryItems` will result
        // in dangling `?` in `url`
        if !parameters.isEmpty {
            urlComponent.queryItems = (urlComponent.queryItems ?? []) + parameters
        }
        return try urlComponent.asURL()
    }
}

public class DefaultTemplateHandler: TemplateHandler {

    public static let shared = DefaultTemplateHandler()

    private var templateValues: [String: () -> String?] = [:]

    private init() { /* Singleton pattern */ }

    public func resolveTemplate(for link: Link) -> String {
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

    public func updateTamplate(for key: String, value: @escaping () -> String?) {
        templateValues.updateValue(value, forKey: key)
    }

    public func removeTemplate(for key: String) {
        templateValues.removeValue(forKey: key)
    }
}

extension URLComponents {

    func asURL() throws -> URL {
        guard let url = url else { throw HalleyKit.Error.cantResolveURLFromString(string: string)}
        return url
    }
}
