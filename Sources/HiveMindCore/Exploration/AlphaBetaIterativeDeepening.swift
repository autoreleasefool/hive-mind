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

	init(maxDepth: Int) {
		self.maxDepth = maxDepth
	}

	// MARK: ExplorationStrategy

	func explore(_ state: GameState, exploration: inout Exploration, step: Step) {
		var currentDepth = 1
		while currentDepth < maxDepth {
			logger.debug("Starting exploring at depth \(currentDepth)")
			do {
				try alphaBetaRoot(depth: currentDepth, state: state, exploration: &exploration, step: step)
			} catch {
				logger.error(error: error, "Exploration canceled.")
			}
			currentDepth += 1
		}
	}

	// MARK: Alpha Beta exploration

	/// Root of the exploration
	private func alphaBetaRoot(
		depth: Int,
		state: GameState,
		exploration: inout Exploration,
		step: Step
	) throws {
		let moves = state.sortMoves(evaluator: exploration.evaluator, with: exploration.support)
		var bestValue = Int.min
		var bestMove = moves.first!

		for move in moves {
			state.apply(move)
			let value = try alphaBetaEvaluate(depth: depth, state: state, exploration: &exploration, alpha: Int.min, beta: Int.max)
			state.undoMove()
			if value > bestValue {
				bestValue = value
				bestMove = move
				step(bestMove)

				logger.debug("Found new best move: \(bestMove)")
			}
		}
	}

	/// Exploration helper method
	private func alphaBetaEvaluate(
		depth: Int,
		state: GameState,
		exploration: inout Exploration,
		alpha: Int,
		beta: Int
	) throws -> Int {
		if depth == 0 {
			return try evaluate(state, exploration: &exploration)
		}

		var updatedAlpha = alpha

		let moves = state.sortMoves(evaluator: exploration.evaluator, with: exploration.support)
		let isMinimizing = state.currentPlayer != exploration.support.hiveMindPlayer
		if isMinimizing {
			var updatedBeta = beta
			for move in moves {
				state.apply(move)
				updatedBeta = min(updatedBeta, try -alphaBetaEvaluate(depth: depth - 1, state: state, exploration: &exploration, alpha: alpha, beta: updatedBeta))
				state.undoMove()
				if updatedBeta < alpha {
					return updatedBeta
				}
			}
			return updatedBeta
		} else {
			for move in moves {
				state.apply(move)
				updatedAlpha = max(updatedAlpha, try alphaBetaEvaluate(depth: depth - 1, state: state, exploration: &exploration, alpha: updatedAlpha, beta: beta))
				state.undoMove()
				if beta < updatedAlpha {
					return updatedAlpha
				}
			}
			return updatedAlpha
		}
	}
}
