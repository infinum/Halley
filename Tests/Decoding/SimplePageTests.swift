import XCTest

final class SimplePageTests: XCTestCase {

    func testPageDecoding() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "page_embedded_response")
        let page = try awaitPublisher(fetcher.resourcePage(ofType: StepItem.self))
        XCTAssertEqual(page.resources?.count, 3)
    }

    func testPagePreserveOrdering() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "page_embedded_response")
        let page = try awaitPublisher(fetcher.resourcePage(ofType: StepItem.self))
        XCTAssertEqual(page.resources?.count, 3)
        XCTAssertEqual(page.resources?[0].description, "First item")
        XCTAssertEqual(page.resources?[1].description, "Second item")
        XCTAssertEqual(page.resources?[2].description, "Third item")
    }

    func testPageWithoutEmbeddedItems() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "page_no_embedded_response",
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
        )
        let page = try awaitPublisher(fetcher.resourcePage(ofType: StepItem.self))
        XCTAssertEqual(page.resources?.count, 3)
    }
}
