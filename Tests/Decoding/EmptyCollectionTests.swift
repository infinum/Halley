import Testing

final class EmptyCollectionTests {

    @Test("Parse empty collection")
    func testParsingEmptyCollection() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "empty_collection_response")
        let items = try await fetcher.resourceCollection(ofType: EmptyResponse.self).values.single()
        #expect(items.isEmpty, "There should be no items.")
    }
}
