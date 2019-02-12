//
//  PositionTests.swift
//  HiveMindEngineTests
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import XCTest
@testable import HiveMindEngine

final class PositionTests: XCTestCase {

    static var allTests = [
        ("testEncodingInPlayPosition", testEncodingInPlayPosition),
        ("testEncodingInHandPosition", testEncodingInHandPosition)
    ]

    func testEncodingInPlayPosition() throws {
        let encoder = JSONEncoder()
        let position: Position = .inPlay(x: 1, y: -1, z: 0)
        let data = try encoder.encode(position)

        let expectation = "{\"inPlay\":{\"x\":1,\"y\":-1,\"z\":0}}"

        XCTAssertEqual(expectation, String.init(data: data, encoding: .utf8)!)

        let decoder = JSONDecoder()
        let decodedPosition: Position = try decoder.decode(Position.self, from: data)
        XCTAssertEqual(position, decodedPosition)
    }

    func testEncodingInHandPosition() throws {
        let encoder = JSONEncoder()
        let position: Position = .inHand
        let data = try encoder.encode(position)

        let decoder = JSONDecoder()
        let decodedPosition: Position = try decoder.decode(Position.self, from: data)
        XCTAssertEqual(position, decodedPosition)
    }

}
