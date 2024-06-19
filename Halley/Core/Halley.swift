import Foundation

// Namespace definition
public enum HalleyKit { }

public extension HalleyKit {

    /// `HalleyKit.Options` is a set of options affecting the decoding and traversing of a HAL response.
    struct Options {

        public static let `default` = Options()

        /// As stated in [JSON Hypertext Application Language](https://datatracker.ietf.org/doc/html/draft-kelly-json-hal) at
        /// section 8.3 of the specification, client can specify behavior in case if both embedded response and link are available for specific resource.
        /// If `false` Halley will ignore embedded response and fetch the resource from available link (if added as included parameter)
        public var preferEmbeddedOverLinkTraversing = true

        /// In case if a same link will be fetched during single traversal - it will reuse the same response
        public var responseFromCache = true

        /// If `true` the result of inital request is a `Failure` if any request for nested resources returns error.
        /// If `false` results of failed nested requests are mapped to `nil` and the result of initial request can still be `Success`.
        public var failWhenAnyNestedRequestErrors = true

        /// Keyword used for embedding collections or links to collection elements
        public var arrayKey = "item"

        /// Pagination metadata resource key
        public var pageMetadataKey = "page"
    }
}

public extension HalleyKit {

    struct Keywords {
        public static let embedded = "_embedded"
        public static let links = "_links"
        public static let `self` = "self"
        public static let includeSeparator: Character = "."

        public struct ToMany {
            /// Leading keyword denoting the start of a "to many" include type
            public static let leading = "["
            /// Trailing keyword denoting the end of a "to many" include type
            public static let trailing = "]"
            /// CharacterSet of leading and trailing keywords
            public static let characterSet = CharacterSet(charactersIn: [leading, trailing].joined())
        }
    }
}

// MARK: - Typealiases

public typealias HalleyConsts = HalleyKit.Keywords
public typealias APIResponse = Result<Data, Error>
public typealias JSONResponse = Result<Any, Error>

/// `Parameters` is a simplification for writing [String: Any]
public typealias Parameters = [String: Any]
