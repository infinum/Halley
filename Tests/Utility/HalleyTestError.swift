import Foundation

enum HalleyTestError: Error {
    case mockError
    case unableToFindMockFile(String)
    case conditionFailed(String)
}
