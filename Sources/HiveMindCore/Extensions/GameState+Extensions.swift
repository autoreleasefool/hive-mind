//
//  GameState+Extensions.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-03.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

extension GameState {
	/// Get all units with available movements
	///
	/// - Parameters:
	///   - player: player to get moveable units for
	func moveableUnits(for player: Player) -> [HiveEngine.Unit] {
		guard let units = unitsInPlay[player] else { return [] }
		return units.keys.filter { $0.availableMoves(in: self).count > 0 }
	}

	/// Count the number of sides of a unit that are empty
	///
	/// - Parameters:
	///   - unit: the unitt to count sides of
	func exposedSides(of unit: HiveEngine.Unit) -> Int {
		return 6 - units(adjacentTo: unit).count
	}

	// API

	/// Get all available moves, sorted based on their estimated value
	///
	/// - Parameters:
	///   - evaluator: to evaluate elements of the movement
	func sortMoves(evaluator: Evaluator, with support: GameStateSupport) -> [Movement] {
		return availableMoves.sorted(by: {
			return evaluator.eval(movement: $0, in: self, with: support) < evaluator.eval(movement: $1, in: self, with: support)
		})
	}

	/// Convert the state to a JSON string
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8) ?? ""
	}
}
