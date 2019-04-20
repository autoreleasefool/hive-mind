//
//  Evaluator.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-28.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import HiveEngine

protocol Evaluator {
	/// Evaluate a `GameState` and return a higher value if it is a better position for the current player.
	/// and a lower value if it a better position for the opponent.
	func eval(state: GameState, with support: GameStateSupport) -> Int

	/// Evaluate a `Unit` based on the current state.
	func eval(unit: Unit, in state: GameState, with support: GameStateSupport) -> Int

	/// Evaluate a `Movement` based on the current state.
	func eval(movement: Movement, in state: GameState, with support: GameStateSupport) -> Int
}
