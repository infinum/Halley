import XCTest

final class SingleResourceWithEmbeddedPage: XCTestCase {

    func testDecodingWhenPageIsEmbeddedAsCollection() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_with_embedded_page",
            for: Contact.self,
            includeType: .contactsAndWebsiteOfContacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/mac_nibblet/contacts", for: .init(jsonName: "antoine_contacts"))
                .adding(url: "http://example.org/api/user/mac_nibblet/website", for: .init(jsonName: "antoine_website"))
        )
        let person = try await awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNotNil(person.website)
        XCTAssertEqual(person.contacts?.first?.contacts?.count, 2)
        XCTAssertNotNil(person.contacts?.first?.website)
    }
}
