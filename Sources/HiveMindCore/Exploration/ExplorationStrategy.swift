//
//  ExplorationStrategy.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-14.
//

import HiveEngine

typealias ExplorationResult = (movement: Movement, statesExplored: Int)

protocol ExplorationStrategy {
	/// Begin exploring the given state. Update the best move when a new one is found
	func play(_ state: GameState) -> ExplorationResult
}

enum ExplorationStrategyType {
	case alphaBeta(depth: Int)
}
