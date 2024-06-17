import XCTest
@testable import Halley

final class CollectionTests: XCTestCase {

    func testFetchingSingleCollectionWithMultipleLinks() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "collection_separate_links",
            for: StepItemResponse.self,
            includeType: .all,
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
                .adding(url: "https://halley.com/step_items", for: .init(jsonName: "step_items"))
        )
        let response = try awaitPublisher(fetcher.resourceCollection(ofType: StepItemResponse.self))
        XCTAssertEqual(response[0].stepItems?.count, 3)
        XCTAssertEqual(response[1].stepItems?.count, 2)
        XCTAssertEqual(response[2].stepItems?.count, 1)
    }

    func testFetchingSingleCollectionWithSingleLink() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "collection_separate_links",
            for: StepItemResponse.self,
            includeType: .all,
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
                .adding(url: "https://halley.com/step_items", for: .init(jsonName: "step_items"))
        )
        let response = try awaitPublisher(fetcher.resourceCollection(ofType: StepItemResponse.self))
        XCTAssertEqual(response[3].stepItems?.count, 2)
    }

    func testEmptyLinksParsing() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "collection_separate_links",
            for: StepItemResponse.self,
            includeType: .all,
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
                .adding(url: "https://halley.com/step_items", for: .init(jsonName: "step_items"))
        )
        let response = try awaitPublisher(fetcher.resourceCollection(ofType: StepItemResponse.self))
        XCTAssertNil(response[4].stepItems)
    }

    func testFetchingSingleResourceWithArrayOfOneLink() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "collection_separate_links",
            for: StepItemResponse.self,
            includeType: .all,
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
                .adding(url: "https://halley.com/step_items", for: .init(jsonName: "step_items"))
        )
        let response = try awaitPublisher(fetcher.resourceCollection(ofType: StepItemResponse.self))
        XCTAssertNotNil(response[5].mainStepItem)
    }

    func testFetchingSingleResourceWithSingleLink() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "collection_separate_links",
            for: StepItemResponse.self,
            includeType: .all,
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
                .adding(url: "https://halley.com/step_items", for: .init(jsonName: "step_items"))
        )
        let response = try awaitPublisher(fetcher.resourceCollection(ofType: StepItemResponse.self))
        XCTAssertNotNil(response[6].mainStepItem)
    }
}
