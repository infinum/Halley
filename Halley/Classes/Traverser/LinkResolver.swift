//
//  LinkResolver.swift
//  Halley
//
//  Created by Zoran Turk on 25.02.2022..
//

import Foundation

public protocol LinkResolver {
    func resolveLink(_ link: Link) throws -> URL
}

public class URLLinkResolver: LinkResolver {
    public init() { }
    public func resolveLink(_ link: Link) throws -> URL {
        return try URL(string: link.href) ?? throwHalleyError(.cantResolveURLFromLink(link: link))
    }
}
