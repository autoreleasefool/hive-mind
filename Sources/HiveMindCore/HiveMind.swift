//
//  HiveMind.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

class HiveMind {

	private(set) var state: GameState
	private let support: GameStateSupport
	private let strategy: ExplorationStrategy
	private let cache: StateCache

	init(state: GameState, strategy: ExplorationStrategy? = nil) {
		let support = GameStateSupport(state: state)
		let cache = try! StateCache()

		self.state = state
		self.support = support
		self.cache = cache
		self.strategy = strategy ?? AlphaBeta(depth: 2, support: support, cache: cache)

		state.requireMovementValidation = false
	}

	convenience init(strategy: ExplorationStrategy? = nil) {
		let state = GameState()
		self.init(state: state, strategy: strategy)
	}

	convenience init(fromJSON jsonString: String) throws {
		let jsonData = jsonString.data(using: .utf8)!
		let decoder = JSONDecoder()
		let state = try decoder.decode(GameState.self, from: jsonData)
		self.init(state: state)
	}

	// MARK: - Play

	func play() -> Movement {
		let explorationResult = strategy.play(state)
		print("Total positions evaluated: \(explorationResult.statesExplored)")

		return explorationResult.movement
	}
}
