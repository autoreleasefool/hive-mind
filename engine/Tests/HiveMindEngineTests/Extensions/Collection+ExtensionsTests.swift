//
//  Collection+ExtensionTests.swift
//  HiveMindEngineTests
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import XCTest
@testable import HiveMindEngine

final class CollectionExtensionTests: XCTestCase {

    static var allTests = [
        ("testCollectionIsNotEmpty", testCollectionIsNotEmpty)
    ]

    func testCollectionIsNotEmpty() {
        var collection: [String] = []
        XCTAssert(collection.isNotEmpty == false)
        collection.append("Hello, world!")
        XCTAssert(collection.isNotEmpty == true)
    }
}
