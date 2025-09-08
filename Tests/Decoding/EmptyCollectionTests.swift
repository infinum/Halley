import XCTest

final class EmptyCollectionTests: XCTestCase {

    func testParsingEmptyCollection() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "empty_collection_response")
        let items = try await fetcher.resourceCollection(ofType: EmptyResponse.self).values.single()
        XCTAssertTrue(items.isEmpty)
    }
}
