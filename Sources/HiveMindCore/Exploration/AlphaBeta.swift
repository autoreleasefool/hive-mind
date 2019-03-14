//
//  AlphaBeta.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-14.
//

import HiveEngine

class AlphaBeta: ExplorationStrategy {

	private var statesEvaluated: Int = 0

	private let explorationDepth: Int
	private let support: GameStateSupport
	private let cache: StateCache

	init(depth: Int, support: GameStateSupport, cache: StateCache) {
		self.explorationDepth = depth
		self.support = support
		self.cache = cache
	}

	func play(_ state: GameState) -> ExplorationResult {
		let movement = alphaBetaRoot(depth: explorationDepth, state: state)
		return (movement, statesEvaluated)
	}

	private func alphaBetaRoot(depth: Int, state: GameState) -> Movement {
		let moves = state.availableMoves
		var bestMove: Movement = state.availableMoves.first!
		var bestValue = Int.min

		moves.forEach {
			state.apply($0)
			let value = alphaBetaEvaluate(depth: depth, state: state, alpha: Int.min, beta: Int.max)
			state.undoMove()
			if value > bestValue {
				bestValue = value
				bestMove = $0
			}
		}

		return bestMove
	}

	private func alphaBetaEvaluate(depth: Int, state: GameState, alpha: Int, beta: Int) -> Int {
		if depth == 0 {
			statesEvaluated += 1
			if statesEvaluated % 1000 == 0 {
				print(statesEvaluated)
			}

			if let value = cache[state] {
				return value
			} else {
				let stateValue = state.evaluate(with: support)
				cache[state] = stateValue
				return stateValue
			}
		}

		var updatedAlpha = alpha

		let isMinimizing = state.currentPlayer != support.hiveMindPlayer
		if isMinimizing {
			var updatedBeta = beta
			for move in state.sortedMoves() {
				state.apply(move)
				updatedBeta = min(updatedBeta, alphaBetaEvaluate(depth: depth - 1, state: state, alpha: alpha, beta: updatedBeta))
				state.undoMove()
				if updatedBeta < alpha {
					return updatedBeta
				}
			}
			return updatedBeta
		} else {
			for move in state.sortedMoves().reversed() {
				state.apply(move)
				updatedAlpha = max(updatedAlpha, alphaBetaEvaluate(depth: depth - 1, state: state, alpha: updatedAlpha, beta: beta))
				state.undoMove()
				if beta < updatedAlpha {
					return updatedAlpha
				}
			}
			return updatedAlpha
		}
	}
}
