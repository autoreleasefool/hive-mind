//
//  HiveMind.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

protocol Actor {
	func apply(movement: Movement)
	func play(completion: @escaping (Movement) -> Void)
}

class HiveMind: Actor {
	struct Options {
		/// Indicates if the HiveMind is the first player (white) or the second (black)
		let isFirst: Bool
		/// Minimum time that the HiveMind should explore a state before it plays
		let minExplorationTime: TimeInterval
		/// The strategy used to explore a state
		let strategyType: ExplorationStrategyType
		/// The strategy used to evaluate a state
		let evaluator: Evaluator
		/// When enabled, the cache will use previous runs and states to explore moves faster
		let cacheDisabled: Bool

		init(
			isFirst: Bool = true,
			minExplorationTime: TimeInterval = 10,
			strategyType: ExplorationStrategyType = .alphaBeta(depth: 2),
			evaluator: @escaping Evaluator = BasicEvaluation.eval,
			cacheDisabled: Bool = false) {
			self.isFirst = isFirst
			self.minExplorationTime = minExplorationTime
			self.strategyType = strategyType
			self.evaluator = evaluator
			self.cacheDisabled = cacheDisabled
		}
	}

	/// The current state being explored
	private let state: GameState

	/// ID of the thread currently executing
	private var currentExplorationId: Int = 0

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
	/// Evaluation function
	private var evaluator: Evaluator

	/// The best move that the HiveMind has come up with so far
	private(set) var bestExploredMoved: Movement?

	/// The best move the HiveMind has come up with so far, or the first move available if it hasn't come up with any moves
	private var bestMove: Movement {
		return bestExploredMoved ?? state.sortedMoves.first!
	}

	/// Enable thread safe access to `responsiveBestMove`
	private let responsiveMoveLock = NSLock()
	/// Thread exploring the current state
	private(set) var explorationThread: Thread?

	/// Minimum time to let a strategy explore a state before returning the best move
	private let minExplorationTime: TimeInterval

	/// Returns true if HiveMind is currently exploring a GameState
	var isExploring: Bool {
		return explorationThread?.isExecuting ?? false
	}

	init(options: Options = Options()) {
		self.state = GameState()
		let cache = StateCache(disabled: options.cacheDisabled)
		self.support = GameStateSupport(isFirst: options.isFirst, state: state, cache: cache)
		self.minExplorationTime = options.minExplorationTime
		self.strategyType = options.strategyType
		self.evaluator = options.evaluator

		self.state.requireMovementValidation = false

		updateExplorationStrategy()
		beginExploration()
	}

	deinit {
		explorationThread?.cancel()
	}

	/// Update the exploration strategy and restart exploration of the current state.
	private func updateExplorationStrategy() {
		switch strategyType {
		case .alphaBeta(let depth):
			strategy = AlphaBeta(depth: depth, evaluator: evaluator, support: support)
		case .alphaBetaIterativeDeepening(let maxDepth):
			strategy = AlphaBetaIterativeDeepening(maxDepth: maxDepth, evaluator: evaluator, support: support)
		}

		// Clear the old exploration strategy and start again
		if isExploring {
			beginExploration()
		}
	}

	// MARK: - Play

	/// Clear the current exploration and begin exploring a state in the background.
	private func beginExploration() {
		guard state.currentPlayer == support.hiveMindPlayer else { return }
		let nextExplorationId = currentExplorationId + 1
		currentExplorationId = nextExplorationId

		explorationThread?.cancel()
		explorationThread = Thread { [weak self] in
			guard let self = self else { return }
			self.explore(self.state, withId: nextExplorationId)
			self.explorationThread = nil
			logger.debug("Finished exploration")
		}

		explorationThread?.start()
	}

	/// Explore a single state and update the best move.
	///
	/// - Parameters:
	///   - state: the state to explore
	private func explore(_ state: GameState, withId id: Int) {
		let exploreState = GameState(from: state)

		strategy.play(exploreState) { [weak self] movement in
			/// Threads don't necessarily stop execution when you cancel them in Swift so we ensure only the most recent exploration can update the best move by capturing the ID of this exploration and comparing it against the most recent ID.
			if id == currentExplorationId {
				self?.bestExploredMoved = movement
			}
		}
	}

	/// Update the state with a move and restart exploration.
	func apply(movement: Movement) {
		defer {
			responsiveMoveLock.unlock()
			beginExploration()
		}

		logger.debug("-----\nApplying move \(movement)...")
		logger.debug("Current state - Move: \(state.move), Player: \(state.currentPlayer)")

		responsiveMoveLock.lock()

		// If the state has already been partially explored, update the current best move
		let currentMove = state.move
		state.apply(movement)

		// Check to make sure the move was valid. If not, exit early
		guard state.move > currentMove else {
			logger.error("The move `\(movement)` was not valid")
			return
		}

		bestExploredMoved = nil

		if state.currentPlayer == support.hiveMindPlayer {
			beginExploration()
		}

		logger.debug("Updated state - Move: \(state.move), Player: \(state.currentPlayer)")
		logger.debug("Done move\n-----")
	}

	/// Return the best move from the current state.
	func play(completion: @escaping (Movement) -> Void) {
		// Wait `minExplorationTime` seconds then return the best move found
		if isExploring == false {
			completion(bestMove)
		} else {
			DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + minExplorationTime) {
				self.explorationThread?.cancel()
				self.explorationThread = nil

				let selectedMove = self.bestMove
				completion(selectedMove)
				self.apply(movement: selectedMove)
			}
		}
	}
}
