//
//  AlphaBetaIterativeDeepening.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-18.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import HiveEngine

class AlphaBetaIterativeDeepening: ExplorationStrategy {

	private let maxDepth: Int

	init(maxDepth: Int, evaluator: Evaluator, support: GameStateSupport) {
		self.maxDepth = maxDepth
		self.evaluator = evaluator
		self.support = support
	}

	// MARK: ExplorationStrategy

	var statesEvaluated: Int = 0
	let support: GameStateSupport
	let evaluator: Evaluator

	func play(_ state: GameState, step: Step) {
		var currentDepth = 1
		while currentDepth <= maxDepth {
			logger.debug("Starting exploring at depth \(currentDepth)")
			alphaBetaRoot(depth: currentDepth, state: state, step: step)
			currentDepth += 1
		}
	}

	// MARK: Alpha Beta exploration

	/// Root of the exploration
	private func alphaBetaRoot(depth: Int, state: GameState, step: Step) {
		let moves = state.sortMoves(evaluator: evaluator, with: support)
		var bestValue = Int.min
		var bestMove = moves.first!

		moves.forEach {
			state.apply($0)
			let value = alphaBetaEvaluate(depth: depth, state: state, alpha: Int.min, beta: Int.max)
			state.undoMove()
			if value > bestValue {
				bestValue = value
				bestMove = $0
				step(bestMove)

				logger.debug("Found new best move: \(bestMove)")
			}
		}
	}

	/// Exploration helper method
	private func alphaBetaEvaluate(depth: Int, state: GameState, alpha: Int, beta: Int) -> Int {
		if depth == 0 {
			return evaluate(state: state)
		}

		var updatedAlpha = alpha

		let moves = state.sortMoves(evaluator: evaluator, with: support)
		let isMinimizing = state.currentPlayer != support.hiveMindPlayer
		if isMinimizing {
			var updatedBeta = beta
			for move in moves {
				state.apply(move)
				updatedBeta = min(updatedBeta, -alphaBetaEvaluate(depth: depth - 1, state: state, alpha: alpha, beta: updatedBeta))
				state.undoMove()
				if updatedBeta < alpha {
					return updatedBeta
				}
			}
			return updatedBeta
		} else {
			for move in moves {
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
