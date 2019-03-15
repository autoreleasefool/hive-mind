//
//  ExplorationStrategy.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-14.
//

import HiveEngine

typealias ExplorationResult = (movement: Movement, statesExplored: Int)

protocol ExplorationStrategy {
	func play(_ state: GameState) -> ExplorationResult
}

enum ExplorationStrategyType {
	case alphaBeta(depth: Int)
}
