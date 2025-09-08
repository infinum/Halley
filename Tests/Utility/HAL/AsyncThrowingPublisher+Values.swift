import Foundation
import Combine

extension AsyncThrowingPublisher {

    func collect() async throws -> [Element] {
        try await reduce(into: []) { $0.append($1) }
    }

    func single() async throws -> Element {
        let items = try await reduce(into: []) { $0.append($1) }

        guard items.count == 1 else {
            throw HalleyTestsError.conditionFailed("Produced \(items.count) items instead of 1.")
        }

        return items[0]
    }
}
