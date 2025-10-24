import Foundation

extension Result {

    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Swift.Error> {
        switch self {
        case let .success(value):
            do {
                return try .success(transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}
