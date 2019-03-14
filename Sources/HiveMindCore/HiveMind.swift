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

	private let hiveMindPlayer: Player
	private(set) var state: GameState
	private let support: GameStateSupport
	private lazy var stateCache: StateCache = {
		return try! StateCache()
	}()

	private var positionsEvaluated: Int = 0

	init(state: GameState) {
		self.state = state
		self.support = GameStateSupport(state: state)
		self.hiveMindPlayer = state.currentPlayer

		state.requireMovementValidation = false
	}

	convenience init() {
		let state = GameState()
		self.init(state: state)
	}

	convenience init(fromJSON jsonString: String) throws {
		let jsonData = jsonString.data(using: .utf8)!
		let decoder = JSONDecoder()
		let state = try decoder.decode(GameState.self, from: jsonData)
		self.init(state: state)
	}

	// MARK: - Play

	func play() -> Movement {
		let movement = alphaBetaRoot(depth: 2, state: state)
		stateCache.flush()
		return movement
	}

	// MARK: Alpha Beta

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
			positionsEvaluated += 1
			if positionsEvaluated % 1000 == 0 {
				print(positionsEvaluated)
			}

			return stateCache.evaluate(state: state, with: support)
		}

		var updatedAlpha = alpha

		let isMinimizing = state.currentPlayer != hiveMindPlayer
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
