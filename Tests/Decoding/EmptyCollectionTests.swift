import XCTest

final class EmptyCollectionTests: XCTestCase {

    func testParsingEmptyCollection() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "empty_collection_response")
        let items = try await awaitPublisher(fetcher.resourceCollection(ofType: EmptyResponse.self))
        XCTAssertTrue(items.isEmpty)
    }
}
