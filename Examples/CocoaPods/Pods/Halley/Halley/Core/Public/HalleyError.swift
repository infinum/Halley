import Foundation

public extension HalleyKit {

    /// `HalleyKit.Error` is the error type returned by HalleyKit.
    enum Error: Swift.Error {
        /// Error thrown in case if `HalleyKit` classes were deinited while traversing the link
        case deinited
        /// Returned when `data` is not [String: Any] or [[String: Any]]
        case cantProcess(data: Any)
        /// Returned when `data` is not [String: Any]
        case notDictionary(data: Any?)
        /// Returned when `data` is not [Any]
        case notArray(data: Any?)
        /// Returned when `data` is not [[String: Any]]
        case notArrayOfDictionaries(data: Any?)
        /// Returned when `relationship` isn't [String: Any], it should be [String: Any]
        case relationshipNotFound(data: Any)
        /// Returned when conversion from NSDictionary to [String: Any] is unsuccessful.
        case unableToConvertNSDictionaryToParams(data: Any)
        /// Returned when conversion from Data to [String: Any] is unsuccessful.
        case unableToConvertDataToJson(data: Any)
        /// Thrown when it is not possible to resolve URL for given link
        case cantResolveURLFromLink(link: Link)
        /// Thrown when it is not possible to resolve URL for given string
        case cantResolveURLFromString(string: String?)
        /// Thrown when the parsing type doesn't match received link - e.g. client expects `toOne`
        /// but the response contains array of links
        case unsupportedLinkType(relationship: String, link: ParsedLink)
    }
}
