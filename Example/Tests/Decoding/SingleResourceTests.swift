//
//  SingleResourceTests.swift
//  Halley_Example
//
//  Created by Filip Gulan on 11.05.2023..
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
import Halley

final class SingleResourceTests: XCTestCase {

    func testDecodingAttributes() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource")
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertTrue(person.name == "Matthew Weier O'Phinney")
    }

    func testDecodingToOneRelationship() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource")
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertNotNil(person.website)
    }

    func testDecodingToManyRelationship() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource")
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertEqual(person.contacts?.count, 2)
    }

    func testDecodingSelfLink() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource")
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertEqual(person._links?.selfLink?.href, "http://example.org/api/user/matthew")
    }

    func testDecodingRelationshipSelfLink() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "simple_single_resource")
        let person = try awaitPublisher(fetcher.resource(ofType: Contact.self))
        XCTAssertEqual(person.website?._links?.selfLink?.href, "http://example.org/api/locations/mwop")
    }
}
