import Testing

final class SingleResourceWithEmbeddedPage {

    @Test("Decoding when page is embedded as collection")
    func testDecodingWhenPageIsEmbeddedAsCollection() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_with_embedded_page",
            for: Contact.self,
            includeType: .contactsAndWebsiteOfContacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/mac_nibblet/contacts", for: .init(jsonName: "antoine_contacts"))
                .adding(url: "http://example.org/api/user/mac_nibblet/website", for: .init(jsonName: "antoine_website"))
        )
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.contacts != nil)
        #expect(person.website != nil)
        #expect(person.contacts?.first?.contacts?.count == 2)
        #expect(person.contacts?.first?.website != nil)
    }
}
