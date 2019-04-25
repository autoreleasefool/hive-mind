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
		/// Indicates if the HiveMind is the first player (white) or the second (black)
		let isFirst: Bool
		/// Minimum time that the HiveMind should explore a state before it plays
		let minExplorationTime: TimeInterval
		/// The strategy used to explore a state
		let strategyType: ExplorationStrategyType
		/// The strategy used to evaluate a state
		let evaluator: Evaluator

		init(
			isFirst: Bool = true,
			minExplorationTime: TimeInterval = 10,
			strategyType: ExplorationStrategyType = .alphaBeta(depth: 2),
			evaluator: Evaluator = BasicEvaluator()) {
			self.isFirst = isFirst
			self.minExplorationTime = minExplorationTime
			self.strategyType = strategyType
			self.evaluator = evaluator
		}
	}

	/// The current state being explored
	private let state: GameState

	/// Cache calculated `GameState` values for faster processing
	private let cache: StateCache

	/// Configuration of the HiveMind
	var options: Options = Options() {
		didSet {
			support = GameStateSupport(isFirst: options.isFirst, state: state, cache: cache)
			updateExplorationStrategy()
		}
	}

	/// Cached properties from the `GameState`
	private var support: GameStateSupport!
	/// Strategy which the HiveMind will employ for exploration
	private var strategy: ExplorationStrategy!

	/// The best move that the HiveMind has come up with so far
	private(set) var bestExploredMoved: Movement?
	/// The best move the HiveMind has come up with so far, or the first move available if it hasn't come up with any moves
	private var bestMove: Movement {
		return bestExploredMoved ?? state.sortMoves(evaluator: options.evaluator, with: support).first!
	}

	/// ID of the thread currently executing
	private var currentExplorationId: Int = 0
	/// Enable thread safe access to `responsiveBestMove`
	private let responsiveMoveLock = NSLock()
	/// Thread exploring the current state
	private(set) var explorationThread: Thread?

	/// Returns true if HiveMind is currently exploring a GameState
	var isExploring: Bool {
		return explorationThread?.isExecuting ?? false
	}

	/// True if the HiveMind is the current player in the state, false otherwise
	var isHiveMindCurrentPlayer: Bool {
		return state.currentPlayer == support.hiveMindPlayer
	}

	init() {
		self.cache = StateCache()
		self.state = GameState()
		self.state.requireMovementValidation = false
	}

	deinit {
		exit()
	}

	/// Update the exploration strategy and restart exploration of the current state.
	private func updateExplorationStrategy() {
		switch options.strategyType {
		case .alphaBeta(let depth):
			strategy = AlphaBeta(depth: depth, evaluator: options.evaluator, support: support)
		case .alphaBetaIterativeDeepening(let maxDepth):
			strategy = AlphaBetaIterativeDeepening(maxDepth: maxDepth, evaluator: options.evaluator, support: support)
		}
	}

	// MARK: - Play

	/// Clear the current exploration and begin exploring a state in the background.
	func beginExploration() {
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

	/// Update the state with a move
	///
	/// - Parameters:
	///   - movement: the movement to apply to the current state
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
	///
	/// - Parameters:
	///   - completion: called with the best movement after exploration completes
	func play(completion: @escaping (Movement) -> Void) {
		// Wait `minExplorationTime` seconds then return the best move found
		if isExploring == false {
			completion(bestMove)
		} else {
			DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + options.minExplorationTime) {
				self.explorationThread?.cancel()
				self.explorationThread = nil

				let selectedMove = self.bestMove
				completion(selectedMove)
				self.apply(movement: selectedMove)
			}
		}
	}

	/// Cancel running operations and clean up state
	func exit() {
		explorationThread?.cancel()
		explorationThread = nil
	}

	// MARK: - Private

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
}
