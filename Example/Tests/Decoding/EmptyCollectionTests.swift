//
//  EmptyCollectionTests.swift
//  Halley_Tests
//
//  Created by Filip Gulan on 11.05.2023..
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest

final class EmptyCollectionTests: XCTestCase {

    func testParsingEmptyCollection() throws {
        let fetcher = HalleyResourceFetcher(fromJson: "empty_collection_response")
        let items = try awaitPublisher(fetcher.resourceCollection(ofType: EmptyResponse.self))
        XCTAssertTrue(items.isEmpty)
    }
}
