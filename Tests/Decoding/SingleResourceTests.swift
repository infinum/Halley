import XCTest
import Halley

final class SingleResourceTests: XCTestCase {

    func testDecodingAttributes() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        XCTAssertTrue(person.name == "Matthew Weier O'Phinney")
    }

    func testDecodingToOneRelationship() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        XCTAssertNotNil(person.website)
    }

    func testDecodingToManyRelationship() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        XCTAssertEqual(person.contacts?.count, 2)
    }

    func testDecodingSelfLink() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        XCTAssertEqual(person._links?.selfLink?.href, "http://example.org/api/user/matthew")
    }

    func testDecodingRelationshipSelfLink() async throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource", for: Contact.self, includeType: .full)
        let person = try await fetcher.resource(ofType: Contact.self).values.single()
        XCTAssertEqual(person.website?._links?.selfLink?.href, "http://example.org/api/locations/mwop")
    }
}
