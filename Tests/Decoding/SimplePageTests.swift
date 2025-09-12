import Testing

final class SimplePageTests {

    @Test("Page decoding")
    func testPageDecoding() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "page_embedded_response")
        let page = try await fetcher.resourcePage(ofType: StepItem.self).values.single()
        #expect(page.resources?.count == 3)
    }

    @Test("Page preserves ordering")
    func testPagePreserveOrdering() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "page_embedded_response")
        let page = try await fetcher.resourcePage(ofType: StepItem.self).values.single()
        #expect(page.resources?.count == 3)
        #expect(page.resources?[0].description == "First item")
        #expect(page.resources?[1].description == "Second item")
        #expect(page.resources?[2].description == "Third item")
    }

    @Test("Page without embedded items")
    func testPageWithoutEmbeddedItems() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "page_no_embedded_response",
            registeredMocks: .shared
                .adding(url: "https://halley.com/items/1", for: .init(jsonName: "step_item_1"))
                .adding(url: "https://halley.com/items/2", for: .init(jsonName: "step_item_2"))
                .adding(url: "https://halley.com/items/3", for: .init(jsonName: "step_item_3"))
        )
        let page = try await fetcher.resourcePage(ofType: StepItem.self).values.single()
        #expect(page.resources?.count == 3)
    }
}
