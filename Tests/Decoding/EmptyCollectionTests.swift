import XCTest

final class EmptyCollectionTests: XCTestCase {

    func testParsingEmptyCollection() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "empty_collection_response")
        let items = try awaitPublisher(fetcher.resourceCollection(ofType: EmptyResponse.self))
        XCTAssertTrue(items.isEmpty)
    }
}
