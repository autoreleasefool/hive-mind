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

	/// Get all available moves, sorted by perceived value
	var sortedMoves: [Movement] {
		return availableMoves.sorted(by: {
			switch ($0, $1) {
			case (.move(let unit1, _), .move(let unit2, _)):
				return unit1.basicValue < unit2.basicValue
			case (.place(let unit1, _), .place(let unit2, _)):
				return unit1.basicValue < unit2.basicValue
			case (.yoink(_, let unit1, _), .yoink(_, let unit2, _)):
				return unit1.basicValue < unit2.basicValue
			case (.move, _): return true
			case (.yoink, _): return true
			case (.place, _): return true
			}
		}).reversed()
	}

	/// Convert the state to a JSON string
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8) ?? ""
	}
}
