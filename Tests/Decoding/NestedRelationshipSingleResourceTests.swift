import Testing
@testable import Halley

final class NestedRelationshipSingleResourceTests {

    @Test("Decoding without embedded relationships")
    func testDecodingWithoutEmbeddedRelationships() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/website", for: .init(jsonName: "matthew_website"))
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )
        let person = try await fetcher.resource(ofType: Contact.self).values.single()

        #expect(person.contacts != nil)
        #expect(person.website != nil)
    }

    @Test("Decoding without embedded relationships (partial)")
    func testDecodingWithoutEmbeddedRelationshipsPartial() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .contacts,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.contacts != nil)
        #expect(person.website == nil)
    }

    @Test("Decoding fetching nested relationship of a relationship")
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
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.contacts != nil)
        #expect(person.website == nil)
        #expect(person.contacts?.first?.contacts?.count == 2)
    }

    @Test("Decoding fetching nested relationships of embedded relationships")
    func testDecodingFetchingNestedRelationshipOfEmbeddedRelationship() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "simple_single_resource",
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

    @Test("Decoding returns error when fetching nested relationship fails")
    func testDecodingReturnsErrorWhenFetchingNestedRelationshipFails() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )

        let result = try? await fetcher.resource(ofType: Contact.self).values.single()

        /// We are expecting an error here since `ResoureFetcher` `includeType` is `full` and
        /// we did not provide URL for  `website` resource in  `registeredMocks`.
        #expect(result == nil)
    }

    @Test("Decoding does return success when fetching nested relationship fails")
    func testDecodingDoesReturnsSuccessWhenFetchingNestedRelationshipFails() async throws {
        let fetcher = HalleyResourceFetcher(
            fromJson: "single_resource_without_embedded",
            for: Contact.self,
            includeType: .full,
            registeredMocks: .shared
                .adding(url: "http://example.org/api/user/matthew/contacts", for: .init(jsonName: "matthew_contacts"))
        )

        let result = try await fetcher.resource(
            ofType: Contact.self,
            options: .init(failWhenAnyNestedRequestErrors: false)
        ).values.single()

        /// We are not expecting an error here even though `ResoureFetcher` `includeType` is `full` and
        /// we did not provide URL for  `website` resource in  `registeredMocks`
        /// because the provided `options` parameter has `failWhenAnyNestedRequestErrors` set to `false`.
        #expect(result.website == nil)
    }
}
