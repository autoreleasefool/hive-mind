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
		let minExplorationTime: TimeInterval
		let strategyType: ExplorationStrategyType
		let cacheDisabled: Bool

		init(minExplorationTime: TimeInterval = 10, strategyType: ExplorationStrategyType = .alphaBetaIterativeDeepening(maxDepth: 6), cacheDisabled: Bool = false) {
			self.minExplorationTime = minExplorationTime
			self.strategyType = strategyType
			self.cacheDisabled = cacheDisabled
		}
	}

	/// The current state being explored
	private let state: GameState

	/// Define the exploration strategy used
	var strategyType: ExplorationStrategyType {
		didSet {
			updateExplorationStrategy()
		}
	}

	/// Cached properties from the `GameState`
	private var support: GameStateSupport
	/// Strategy which the HiveMind will employ for exploration
	private var strategy: ExplorationStrategy!
	/// State evaluation cache
	private let cache: StateCache

	/// The best move that the HiveMind has come up with so far
	private(set) var currentBestMove: Movement
	/// Thread exploring the current state
	private(set) var explorationThread: Thread?

	/// Minimum time to let a strategy explore a state before returning the best move
	private let minExplorationTime: TimeInterval

	/// Returns true if HiveMind is currently exploring a GameState
	var isExploring: Bool {
		return explorationThread?.isExecuting ?? false
	}

	init(options: Options = Options()) throws {
		self.state = GameState()
		self.support = GameStateSupport(state: state)
		self.currentBestMove = state.availableMoves.first!
		self.cache = try StateCache(disabled: options.cacheDisabled)
		self.minExplorationTime = options.minExplorationTime
		self.strategyType = options.strategyType

		self.state.requireMovementValidation = false
		self.currentBestMove = state.availableMoves.first!

		beginExploration()
	}

	deinit {
		explorationThread?.cancel()
	}

	/// Update the exploration strategy and restart exploration of the current state.
	private func updateExplorationStrategy() {
		switch strategyType {
		case .alphaBeta(let depth):
			self.strategy = AlphaBeta(depth: depth, support: support, cache: cache)
		case .alphaBetaIterativeDeepening(let maxDepth):
			self.strategy = AlphaBetaIterativeDeepening(maxDepth: maxDepth, support: support, cache: cache)
		}

		// Clear the old exploration strategy and start again
		if isExploring {
			beginExploration()
		}
	}

	// MARK: - Play

	/// Clear the current exploration and begin exploring a state in the background.
	private func beginExploration() {
		explorationThread?.cancel()
		explorationThread = Thread { [weak self] in
			guard let self = self else { return }
			self.strategy.play(self.state, bestMove: &self.currentBestMove)
			self.explorationThread = nil
		}
	}

	/// Update the state with a move and restart exploration.
	func apply(movement: Movement) {
		state.apply(movement)
		beginExploration()
	}

	/// Return the best move from the current state.
	func play(completion: @escaping (Movement) -> Void) {
		// Wait `minExplorationTime` seconds then return the best move found
		if isExploring == false {
			completion(self.currentBestMove)
		} else {
			DispatchQueue.main.asyncAfter(deadline: .now() + minExplorationTime) {
				self.explorationThread?.cancel()
				self.explorationThread = nil
				completion(self.currentBestMove)

				// Update state with the returned move and begin exploring the new state
				self.state.apply(self.currentBestMove)
				self.beginExploration()
			}
		}
	}
}
