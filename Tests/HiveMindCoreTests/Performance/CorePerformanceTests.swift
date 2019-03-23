//
//  CorePerformanceTests.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-15.
//

import XCTest
import HiveEngine
@testable import HiveMindCore

final class CorePerformanceTests: XCTestCase {

	var stateProvider: GameStateProvider!

	override func setUp() {
		super.setUp()
		stateProvider = GameStateProvider()
	}

	func testAlphaBetaStrategyOpeningMovePerformance() {
		let options = HiveMind.Options(minExplorationTime: 30, strategyType: .alphaBeta(depth: 2), cacheDisabled: true)
		guard let hiveMind = try? HiveMind(options: options) else {
			XCTFail("Failed to initialize HiveMind")
			return
		}

		measure {
			let expectation = XCTestExpectation(description: "HiveMind found the best move.")
			_ = hiveMind.play() { _ in expectation.fulfill() }
			wait(for: [expectation], timeout: 30)
		}
	}

	func testEvaluationPerformance() {
		let state = stateProvider.initialGameState
		stateProvider.apply(moves: 20, to: state)

		let support = GameStateSupport(state: state)
		measure {
			for _ in 0..<100 {
				_ = state.evaluate(with: support)
			}
		}
	}

	static var allTests = [
		("testAlphaBetaStrategyOpeningMovePerformance", testAlphaBetaStrategyOpeningMovePerformance),
		("testEvaluationPerformance", testEvaluationPerformance)
	]
}
