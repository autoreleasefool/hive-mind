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
		let hiveMind = HiveMind(strategy: .alphaBeta(depth: 2), cacheDisabled: true)
		measure {
			_ = hiveMind.play()
		}
	}

	func testEvaluationPerformance() {
		let state = stateProvider.initialGameState
		stateProvider.apply(moves: 20, to: state)

		let support = GameStateSupport(state: state)
		measure {
			for _ in 0..<1000 {
				_ = state.evaluate(with: support)
			}
		}
	}

	static var allTests = [
		("testAlphaBetaStrategyOpeningMovePerformance", testAlphaBetaStrategyOpeningMovePerformance),
		("testEvaluationPerformance", testEvaluationPerformance)
	]
}
