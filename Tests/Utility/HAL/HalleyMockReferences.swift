import Foundation

typealias HalleyMockReferences = [String: HalleyMockReference]

extension HalleyMockReferences {

    static let baseUrl = "https://halley.com"

    /// Contains base fixtures used while fetching mocked resources
    /// Please don't modify URLs in this list since URLs aren't typesafe and replacing/removing
    /// one reference here could result in multiple resources not being able to fetch their sub-resources in tests.
    /// If needed, rather update on call site and change the referencing JSON file or Bundle
    static let shared: HalleyMockReferences = [:]
}

extension HalleyMockReferences {

    func adding(url: String, for reference: HalleyMockReference) -> HalleyMockReferences {
        var result = self
        result[url] = reference
        return result
    }

    func removing(url: String) -> HalleyMockReferences {
        var result = self
        result.removeValue(forKey: url)
        return result
    }

    func joining(with other: HalleyMockReferences) -> HalleyMockReferences {
        return merging(other, uniquingKeysWith: { _, new in new })
    }
}
