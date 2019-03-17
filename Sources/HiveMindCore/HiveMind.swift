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

	init(state: GameState = GameState(), strategy: ExplorationStrategyType? = nil, cacheDisabled: Bool = false) throws {
		let support = GameStateSupport(state: state)
		let cache = try StateCache(disabled: cacheDisabled)

		self.state = state
		self.support = support
		self.cache = cache

		let chosenStrategy = strategy ?? .alphaBeta(depth: 2)
		switch chosenStrategy {
		case .alphaBeta(let depth):
			self.strategy = AlphaBeta(depth: depth, support: support, cache: cache)
		}

		state.requireMovementValidation = false
	}

	convenience init(fromJSON jsonString: String) throws {
		let jsonData = jsonString.data(using: .utf8)!
		let decoder = JSONDecoder()
		let state = try decoder.decode(GameState.self, from: jsonData)
		try self.init(state: state)
	}

	// MARK: - Play

	func play() -> Movement {
		let explorationResult = strategy.play(state)
		logger.debug("Total positions evaluated: \(explorationResult.statesExplored)")
		cache.flush()

		return explorationResult.movement
	}
}
