import XCTest
@testable import Halley

final class NestedRelationshipSingleResourceTests: XCTestCase {

    func testDecodingWithoutEmbeddedRelationships() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/website", for: .init(jsonName: "matthew_website"))
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )
        let person = try await awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNotNil(person.website)
    }

    func testDecodingWithoutEmbeddedRelationshipsPartial() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .contacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )
        let person = try await awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNil(person.website)
    }

    func testDecodingFetchingNestedRelationshipOfARelationship() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .contactsOfContacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/website", for: .init(jsonName: "matthew_website"))
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
                .adding(url: "http://example.org/api/user/mac_nibblet/contacts", for: .init(jsonName: "antoine_contacts"))
        )
        let person = try await awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.contacts)
        XCTAssertNil(person.website)
        XCTAssertEqual(person.contacts?.first?.contacts?.count, 2)
    }

    func testDecodingFetchingNestedRelationshipOfEmbeddedRelationship() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "simple_single_resource",
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

    func testDecodingReturnsErrorWhenFetchingNestedRelationshipFails() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )

        let result = try? await awaitPublisher(fetcher.resource(ofType: Contact.self))

        /// We are expecting an error here since `ResoureFetcher` `includeType` is `full` and
        /// we did not provide URL for  `website` resource in  `registeredMocks`.
        XCTAssertNil(result)
    }

    func testDecodingDoesReturnsSuccessWhenFetchingNestedRelationshipFails() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )

        let options = HalleyKit.Options(failWhenAnyNestedRequestErrors: false)

        let result = try await awaitPublisher(fetcher.resource(ofType: Contact.self, options: options))
        
        /// We are not expecting an error here even though `ResoureFetcher` `includeType` is `full` and
        /// we did not provide URL for  `website` resource in  `registeredMocks`
        /// because the provided `options` parameter has `failWhenAnyNestedRequestErrors` set to `false`.
        XCTAssertNoThrow(result)
    }
}
