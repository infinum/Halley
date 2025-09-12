import Testing

final class SingleResourceTests {

    @Test("Decoding attributes")
    func testDecodingAttributes() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.name == "Matthew Weier O'Phinney")
    }

    @Test("Decoding to one relationship")
    func testDecodingToOneRelationship() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.website != nil)
    }

    @Test("Deco to many relationship")
    func testDecodingToManyRelationship() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.contacts?.count == 2)
    }

    @Test("Decoding self link")
    func testDecodingSelfLink() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person._links?.selfLink?.href == "http://example.org/api/user/matthew")
    }

    @Test("Decoding relationship self link")
    func testDecodingRelationshipSelfLink() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        #expect(person.website?._links?.selfLink?.href == "http://example.org/api/locations/mwop")
    }
}
