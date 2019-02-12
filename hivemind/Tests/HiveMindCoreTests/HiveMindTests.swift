//
//  HiveMindCoreTests.swift
//  HiveMindCoreTests
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import XCTest
@testable import HiveMindCore

final class HiveMindCoreTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(HiveMind().test, 0)
    }

    static var allTests = [
        ("testExample", testExample)
    ]
}
