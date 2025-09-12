import Testing

final class CollectionTests {

    @Test("Fetching single collection with multiple links")
    func testFetchingSingleCollectionWithMultipleLinks() async throws {
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
        let response = try await fetcher.resourceCollection(ofType: StepItemResponse.self).values.single()
        #expect(response[0].stepItems?.count == 3)
        #expect(response[1].stepItems?.count == 2)
        #expect(response[2].stepItems?.count == 1)
    }

    @Test("Fetching single collection with single link")
    func testFetchingSingleCollectionWithSingleLink() async throws {
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
        let response = try await fetcher.resourceCollection(ofType: StepItemResponse.self).values.single()
        #expect(response[3].stepItems?.count == 2)
    }

    @Test("Empty links parsing")
    func testEmptyLinksParsing() async throws {
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
        let response = try await fetcher.resourceCollection(ofType: StepItemResponse.self).values.single()
        #expect(response[4].stepItems == nil)
    }

    @Test("Fetching single resource with array of one link")
    func testFetchingSingleResourceWithArrayOfOneLink() async throws {
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
        let response = try await fetcher.resourceCollection(ofType: StepItemResponse.self).values.single()
        #expect(response[5].mainStepItem != nil)
    }

    @Test("Fetching single resource with a single link")
    func testFetchingSingleResourceWithSingleLink() async throws {
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
        let response = try await fetcher.resourceCollection(ofType: StepItemResponse.self).values.single()
        #expect(response[6].mainStepItem != nil)
    }
}
