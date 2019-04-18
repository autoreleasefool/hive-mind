//
//  ExplorationStrategy.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-14.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import HiveEngine

protocol ExplorationStrategy: class {
	typealias Step = (Movement) -> Void

	/// Total number of states evaluated
	var statesEvaluated: Int { get set }
	/// Cached state properties
	var support: GameStateSupport { get }
	/// Evaluation function
	var evaluator: Evaluator { get }

	/// Begin exploring the given state. Calls `step` with each new best move as one is found.
	func play(_ state: GameState, step: Step)

	/// Evaluate a game state
	func evaluate(state: GameState) -> Int
}

extension ExplorationStrategy {
	func evaluate(state: GameState) -> Int {
		statesEvaluated += 1
		if statesEvaluated % 10000 == 0 {
			logger.debug("States evaluated: \(statesEvaluated)")
		}

		if let value = support.cache[state] {
			return value
		} else {
			let stateValue = evaluator(state, support)
			support.cache[state] = stateValue
			return stateValue
		}
	}
}

enum ExplorationStrategyType {
	case alphaBeta(depth: Int)
	case alphaBetaIterativeDeepening(maxDepth: Int)
}
