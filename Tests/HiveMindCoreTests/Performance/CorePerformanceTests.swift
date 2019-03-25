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
		guard let hiveMind = try? HiveMind(isFirst: true, options: options) else {
			XCTFail("Failed to initialize HiveMind")
			return
		}

		measure {
			let expectation = XCTestExpectation(description: "HiveMind found the best move.")
			_ = hiveMind.play { _ in expectation.fulfill() }
			wait(for: [expectation], timeout: 30)
		}
	}

	func testEvaluationPerformance() throws {
		let state = stateProvider.initialGameState
		let cache = try StateCache(useHistory: false, disabled: true)
		stateProvider.apply(moves: 20, to: state)

		let support = GameStateSupport(isFirst: true, state: state, cache: cache)
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
