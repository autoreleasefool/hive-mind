//
//  CorePerformanceTests.swift
//  HiveMindCoreTests
//
//  Created by Joseph Roque on 2019-03-15.
//  Copyright © 2019 Joseph Roque. All rights reserved.
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

	func testBasicEvaluationPerformance() throws {
		let state = stateProvider.initialGameState
		let cache = try StateCache(useHistory: false, disabled: true)
		stateProvider.apply(moves: 20, to: state)

		let support = GameStateSupport(isFirst: true, state: state, cache: cache)
		let evaluator = BasicEvaluation.eval
		measure {
			for _ in 0..<100 {
				_ = evaluator(state, support)
			}
		}
	}

	static var allTests = [
		("testBasicEvaluationPerformance", testBasicEvaluationPerformance)
	]
}
