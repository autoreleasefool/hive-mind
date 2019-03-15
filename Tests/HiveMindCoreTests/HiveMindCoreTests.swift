//
//  HiveMindCoreTests.swift
//  HiveMindCoreTests
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import XCTest
import HiveEngine
@testable import HiveMindCore

final class HiveMindCoreTests: XCTestCase {

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

	func testAlphaBetaStrategyMidGameMovePerformance() {
		let state = stateProvider.initialGameState
		let setupMoves: [Movement] = [
			.place(unit: state.whiteQueen, at: Position(x: 0, y: 0, z: 0)),
			.place(unit: state.blackQueen, at: Position(x: 0, y: 1, z: -1)),
			.place(unit: state.whiteAnt, at: Position(x: 0, y: -1, z: 1)),
			.place(unit: state.blackBeetle, at: Position(x: 0, y: 2, z: -2)),
			.place(unit: state.whiteLadyBug, at: Position(x: -1, y: 0, z: 1)),
			.place(unit: state.blackAnt, at: Position(x: 1, y: 1, z: -2))
		]

		stateProvider.apply(moves: setupMoves, to: state)

		let hiveMind = HiveMind(state: state, strategy: .alphaBeta(depth: 2), cacheDisabled: true)
		measure {
			_ = hiveMind.play()
		}
	}

	func testAlphaBetaStrategyEndGameMovePerformance() {
		let state = stateProvider.initialGameState
		stateProvider.apply(moves: 33, to: state)

		let hiveMind = HiveMind(state: state, strategy: .alphaBeta(depth: 2), cacheDisabled: true)
		measure {
			_ = hiveMind.play()
		}
	}

	static var allTests = [
		("testAlphaBetaStrategyOpeningMovePerformance", testAlphaBetaStrategyOpeningMovePerformance),
		("testAlphaBetaStrategyMidGameMovePerformance", testAlphaBetaStrategyMidGameMovePerformance),
		("testAlphaBetaStrategyEndGameMovePerformance", testAlphaBetaStrategyEndGameMovePerformance)
	]
}
