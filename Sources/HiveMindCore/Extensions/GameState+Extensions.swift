//
//  GameState+Extensions.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-03.
//

import Foundation
import HiveEngine

extension GameState {
	/// Evaluate a GameState and return a higher value if it is a better position for the HiveMind,
	/// and a lower value if it is a better position for the opponent.
	func evaluate(with support: GameStateSupport) -> Int {
		let opponent = currentPlayer.next

		let hiveMindQueen: HiveEngine.Unit
		let opponentQueen: HiveEngine.Unit
		switch currentPlayer {
		case .white:
			hiveMindQueen = support.whiteQueen
			opponentQueen = support.blackQueen
		case .black:
			hiveMindQueen = support.blackQueen
			opponentQueen = support.whiteQueen
		}

		// Look for lose condition and set to min priority
		let hiveMindQueenSidesRemaining = exposedSides(of: hiveMindQueen)
		if hiveMindQueenSidesRemaining == 0 {
			return Int.min
		}

		// Look for win condition and set to max priority
		let opponentQueenSidesRemaining = exposedSides(of: opponentQueen)
		if opponentQueenSidesRemaining == 0 {
			return Int.max
		}

		// Don't let the opponent shut you out
		if self.anyMovesAvailable(for: currentPlayer) == false {
			return Int.min + 1
		}

		var value = 0
		let hiveMindUnitsInPlay = unitsInPlay[currentPlayer]! // 0 to 14
		hiveMindUnitsInPlay.forEach {
			value += $0.key.value(in: self)
		}

		let opponentUnitsInPlay = unitsInPlay[opponent]! // 0 to 14
		opponentUnitsInPlay.forEach {
			value += $0.key.value(in: self)
		}

		return value * (6 - opponentQueenSidesRemaining)
	}

	/// Get all units with available movements
	///
	/// - Parameters:
	///   - player: player to get moveable units for
	private func moveableUnits(for player: Player) -> [HiveEngine.Unit] {
		guard let units = unitsInPlay[player] else { return [] }
		return units.keys.filter { $0.availableMoves(in: self).count > 0 }
	}

	/// Count the number of sides of a unit that are empty
	///
	/// - Parameters:
	///   - unit: the unitt to count sides of
	private func exposedSides(of unit: HiveEngine.Unit) -> Int {
		return 6 - units(adjacentTo: unit).count
	}

	// API

	/// Get all available moves, sorted by perceived value
	func sortedMoves() -> [Movement] {
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
		})
	}

	/// Convert the state to a JSON string
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8)!
	}
}
