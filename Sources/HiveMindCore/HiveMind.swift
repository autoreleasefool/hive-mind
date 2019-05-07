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
		/// Maximum time that the HiveMind should explore a state before it plays
		let maxExplorationTime: TimeInterval
		/// The strategy used to explore a state
		let strategyType: ExplorationStrategyType
		/// The strategy used to evaluate a state
		let evaluator: Evaluator

		init(
			isFirst: Bool = true,
			maxExplorationTime: TimeInterval = 10,
			strategyType: ExplorationStrategyType = .alphaBetaIterativeDeepening(maxDepth: 4),
			evaluator: Evaluator = BasicEvaluator()) {
			self.isFirst = isFirst
			self.maxExplorationTime = maxExplorationTime
			self.strategyType = strategyType
			self.evaluator = evaluator
		}
	}

	/// The current state being explored
	private var state: GameState {
		didSet {
			support = GameStateSupport(isFirst: options.isFirst, state: state, cache: cache)
			updateExplorationStrategy()
			bestExploredMove = nil
		}
	}

	private static var defaultGameState: GameState {
		return GameState(options: [.ladyBug, .mosquito, .pillBug, .disableMovementValidation, .allowSpecialAbilityAfterYoink, .restrictedOpening])
	}

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
	private var bestExploredMove: Movement?
	/// The best move the HiveMind has come up with so far, or the first move available if it hasn't come up with any moves
	private var bestMove: Movement {
		return bestExploredMove ?? state.sortMoves(evaluator: options.evaluator, with: support).first!
	}

	/// True if the HiveMind is the current player in the state, false otherwise
	var isHiveMindCurrentPlayer: Bool {
		return state.currentPlayer == support.hiveMindPlayer
	}

	init() {
		self.cache = StateCache()
		self.state = HiveMind.defaultGameState
	}

	/// Update the exploration strategy
	private func updateExplorationStrategy() {
		switch options.strategyType {
		case .alphaBetaIterativeDeepening(let maxDepth):
			strategy = AlphaBetaIterativeDeepening(maxDepth: maxDepth)
		}
	}

	// MARK: - Play

	/// Clear the current exploration and begin exploring a state in the background.
	func beginExploration() {
		guard state.currentPlayer == support.hiveMindPlayer else { return }
		explore(state)
		logger.debug("Finished exploration")
	}

	/// Update the state with a move. Returns true if the movement was valid, false otherwise
	///
	/// - Parameters:
	///   - movement: the movement to apply to the current state
	func apply(movement: Movement) -> Bool {
		logger.debug("Applying move \(movement) -----")
		logger.debug("Current state - Move: \(state.move), Player: \(state.currentPlayer)")

		let currentMove = state.move
		state.apply(movement)

		// Check to make sure the move was valid. If not, exit early
		guard state.move > currentMove else {
			logger.error("The move `\(movement)` was not valid")
			return false
		}

		bestExploredMove = nil

		logger.debug("Updated state - Move: \(state.move), Player: \(state.currentPlayer)")
		logger.debug("Done move -----")

		return true
	}

	/// Return the best move from the current state.
	func play() -> Movement {
		if let bestExploredMove = self.bestExploredMove {
			return bestExploredMove
		} else {
			beginExploration()
			return bestMove
		}
	}

	/// Cancel running operations and return to initial state.
	func restart() {
		state = HiveMind.defaultGameState
	}

	// MARK: - Private

	/// Explore a single state and update the best move.
	///
	/// - Parameters:
	///   - state: the state to explore
	private func explore(_ state: GameState) {
		let exploreState = GameState(from: state)

		let startTime = Date()
		let endTime = Date(timeInterval: options.maxExplorationTime, since: startTime)
		var exploration = Exploration(startTime: startTime, deadline: endTime, support: support, evaluator: options.evaluator)

		strategy.explore(exploreState, exploration: &exploration) { [weak self] movement in
			self?.bestExploredMove = movement
		}
	}
}
