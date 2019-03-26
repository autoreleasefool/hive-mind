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

	/// The best move that the HiveMind has come up with so far
	private(set) var currentBestMove: Movement
	/// The best move the HiveMind has come up with so far for a given state.
	private(set) var responsiveBestMove: [Int: Movement] = [:]

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

	init(isFirst: Bool, options: Options = Options()) throws {
		self.state = GameState()
		let cache = try StateCache(disabled: options.cacheDisabled)
		self.support = GameStateSupport(isFirst: isFirst, state: state, cache: cache)
		self.minExplorationTime = options.minExplorationTime
		self.strategyType = options.strategyType

		self.state.requireMovementValidation = false
		self.currentBestMove = state.availableMoves.first!

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
			self.strategy = AlphaBeta(depth: depth, support: support)
		case .alphaBetaIterativeDeepening(let maxDepth):
			self.strategy = AlphaBetaIterativeDeepening(maxDepth: maxDepth, support: support)
		}

		// Clear the old exploration strategy and start again
		if isExploring {
			beginExploration()
		}
	}

	// MARK: - Play

	/// Clear the current exploration and begin exploring a state in the background.
	private func beginExploration() {
		defer { responsiveMoveLock.unlock() }
		responsiveMoveLock.lock()
		responsiveBestMove.removeAll()

		explorationThread?.cancel()
		explorationThread = Thread { [weak self] in
			guard let self = self else { return }

			if self.state.currentPlayer == self.support.hiveMindPlayer {
				// If it's the HiveMind's move, simply find the best move for the given state
				self.explore(self.state)
			} else {
				// If it's the opponent's move, find the best response to all of opponent's possible moves
				self.exploreSubsequent(to: self.state)
			}

			self.explorationThread = nil
		}

		explorationThread?.start()
	}

	/// Explore a single state and update the best move.
	///
	/// - Parameters:
	///   - state: the state to explore
	private func explore(_ state: GameState) {
		self.strategy.play(self.state) { [weak self] movement in
			self?.currentBestMove = movement
		}
	}

	/// Explore a state's subsequent states (each state created after applying a single valid move)
	/// and update the best move in response to each.
	///
	/// - Parameters:
	///   - state: the state whose subsequent states will be explored.
	private func exploreSubsequent(to state: GameState) {
		let moves = state.sortedMoves()
		DispatchQueue.concurrentPerform(iterations: moves.count) { [weak self] iteration in
			guard let self = self else { return }
			let subsequentState = GameState(from: self.state)
			subsequentState.apply(moves[iteration])

			self.strategy.play(subsequentState) { [weak self] response in
				guard let self = self else { return }
				defer { responsiveMoveLock.unlock() }
				responsiveMoveLock.lock()
				self.responsiveBestMove[subsequentState.fastHash(with: support)] = response
			}
		}
	}

	/// Update the state with a move and restart exploration.
	func apply(movement: Movement) {
		defer {
			responsiveMoveLock.unlock()
			beginExploration()
		}

		responsiveMoveLock.lock()

		// If the state has already been partially explored, update the current best move
		let currentMove = state.move
		state.apply(movement)

		// Check to make sure the move was valid. If not, exit early
		guard state.move > currentMove else {
			logger.debug("The move `\(movement)` was not valid")
			return
		}

		if let currentBestMove = responsiveBestMove[state.fastHash(with: support)] {
			self.currentBestMove = currentBestMove
		} else {
			// FIXME: consider when hivemind has no moves
			self.currentBestMove = state.availableMoves.first!
		}
	}

	/// Return the best move from the current state.
	func play(completion: @escaping (Movement) -> Void) {
		// Wait `minExplorationTime` seconds then return the best move found
		if isExploring == false {
			completion(self.currentBestMove)
		} else {
			DispatchQueue.global().asyncAfter(deadline: .now() + minExplorationTime) {
				self.explorationThread?.cancel()
				self.explorationThread = nil
				completion(self.currentBestMove)

				// Update state with the returned move and begin exploring the new state
				self.apply(movement: self.currentBestMove)
			}
		}
	}
}
