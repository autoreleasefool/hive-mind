//
//  ExplorationStrategy.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-14.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

enum ExplorationError: LocalizedError {
	case outOfTime
	case threadCancelled

	var errorDescription: String? {
		switch self {
		case .outOfTime: return "Exploration ran out of time before finishing."
		case .threadCancelled: return "Thread was cancelled by parent."
		}
	}
}

struct Exploration {
	/// Time that the Exploration began
	let startTime: Date
	/// Time that the Exploration must be completed by
	let deadline: Date

	/// Cached state properties
	let support: GameStateSupport
	/// Evaluation methods
	let evaluator: Evaluator

	/// Total number of states evaluated in this exploration
	var statesEvaluated: Int = 0

	/// Indicates if the exploration has been cancelled.
	var cancelled: Bool = false

	init(startTime: Date, deadline: Date, support: GameStateSupport, evaluator: Evaluator) {
		self.startTime = startTime
		self.deadline = deadline
		self.support = support
		self.evaluator = evaluator
	}
}

protocol ExplorationStrategy: class {
	typealias Step = (Movement) -> Void

	/// Begin exploring the given state. Calls `step` with each new best move as one is found.
	func explore(_ state: GameState, exploration: inout Exploration, step: Step)

	/// Evaluate a game state
	func evaluate(_ state: GameState, exploration: inout Exploration) throws -> Int
}

extension ExplorationStrategy {
	func evaluate(_ state: GameState, exploration: inout Exploration) throws -> Int {
		guard Date() < exploration.deadline else {
			throw ExplorationError.outOfTime
		}

		guard exploration.cancelled == false else {
			throw ExplorationError.threadCancelled
		}

		exploration.statesEvaluated += 1
		if exploration.statesEvaluated % 10000 == 0 {
			logger.debug("States evaluated: \(exploration.statesEvaluated)")
		}

		if let value = exploration.support.cache[state] {
			return value
		} else {
			let stateValue = exploration.evaluator.eval(state: state, with: exploration.support)
			exploration.support.cache[state] = stateValue
			return stateValue
		}
	}
}

enum ExplorationStrategyType {
	case alphaBeta(depth: Int)
	case alphaBetaIterativeDeepening(maxDepth: Int)
}
