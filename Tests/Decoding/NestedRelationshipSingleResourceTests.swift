import XCTest

final class NestedRelationshipSingleResourceTests: XCTestCase {

    func testDecodingWithoutEmbeddedRelationships() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/website", for: .init(jsonName: "matthew_website"))
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNotNil(person.website)
    }

    func testDecodingWithoutEmbeddedRelationshipsPartial() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .contacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNil(person.website)
    }

    func testDecodingFetchingNestedRelationshipOfARelationship() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .contactsOfContacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/website", for: .init(jsonName: "matthew_website"))
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
                .adding(url: "http://example.org/api/user/mac_nibblet/contacts", for: .init(jsonName: "antoine_contacts"))
        )
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNil(person.website)
        XCTAssertEqual(person.contacts?.first?.contacts?.count, 2)
    }

    func testDecodingFetchingNestedRelationshipOfEmbeddedRelationship() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "simple_single_resource",
            for: Contact.self,
            includeType: .contactsAndWebsiteOfContacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/mac_nibblet/contacts", for: .init(jsonName: "antoine_contacts"))
                .adding(url: "http://example.org/api/user/mac_nibblet/website", for: .init(jsonName: "antoine_website"))
        )
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNotNil(person.website)
        XCTAssertEqual(person.contacts?.first?.contacts?.count, 2)
        XCTAssertNotNil(person.contacts?.first?.website)
    }

    func testDecodingReturnsErrorWhenFetchingNestedRelationshipFails() throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )

        /// We are expecting an error here since `ResoureFetcher` `includeType` is `full` and
        /// we did not provide URL for  `website` resource in  `registeredMocks`.
        XCTAssertThrowsError(try awaitPublisher(fetcher.resource(ofType: Contact.self)))
    }
}
