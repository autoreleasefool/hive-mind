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

	struct Options {
		let minExplorationTime: TimeInterval = 10
		let strategy: ExplorationStrategyType = .alphaBeta(depth: 2)
		let cacheDisabled: Bool = false
	}

	/// The current state being explored
	private(set) var state: GameState
	/// Cached properties from the `GameState`
	private let support: GameStateSupport
	/// Strategy which the HiveMind will employ for exploration
	private let strategy: ExplorationStrategy
	/// State evaluation cache
	private let cache: StateCache

	/// The best move that the HiveMind has come up with so far
	private(set) var currentBestMove: Movement?

	/// Minimum time to let a strategy explore a state before returning the best move
	private let minExplorationTime: TimeInterval

	init(state: GameState = GameState(), options: Options = Options()) throws {
		let support = GameStateSupport(state: state)
		let cache = try StateCache(disabled: options.cacheDisabled)

		self.state = state
		self.support = support
		self.cache = cache
		self.minExplorationTime = options.minExplorationTime

		switch options.strategy {
		case .alphaBeta(let depth):
			self.strategy = AlphaBeta(depth: depth, support: support, cache: cache)
		}

		state.requireMovementValidation = false
	}

	convenience init(fromJSON jsonString: String) throws {
		let jsonData = jsonString.data(using: .utf8)!
		let decoder = JSONDecoder()
		let state = try decoder.decode(GameState.self, from: jsonData)
		try self.init(state: state, options: Options())
	}

	// MARK: - Play

	/// Return the best move from the current state.
	func play() -> Movement {
		let explorationResult = strategy.play(state)
		logger.debug("Total positions evaluated: \(explorationResult.statesExplored)")
		cache.flush()

		return explorationResult.movement
	}
}
