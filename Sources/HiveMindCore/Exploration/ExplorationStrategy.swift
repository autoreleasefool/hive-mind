//
//  ExplorationStrategy.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-14.
//

import HiveEngine

protocol ExplorationStrategy: class {
	/// Total number of states evaluated
	var statesEvaluated: Int { set get }
	/// Cached state properties
	var support: GameStateSupport { get }
	/// Game state evaluation cache
	var cache: StateCache { get }

	/// Begin exploring the given state. Update the best move when a new one is found
	func play(_ state: GameState, bestMove: inout Movement)

	/// Evaluate a game state
	func evaluate(state: GameState) -> Int
}

extension ExplorationStrategy {
	func evaluate(state: GameState) -> Int {
		statesEvaluated += 1
		if statesEvaluated % 1000 == 0 {
			logger.debug("States evaluazted: \(statesEvaluated)")
		}

		if let value = cache[state] {
			return value
		} else {
			let stateValue = state.evaluate(with: support)
			cache[state] = stateValue
			return stateValue
		}
	}
}

enum ExplorationStrategyType {
	case alphaBeta(depth: Int)
}
