//
//  GameState+Extensions.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-03.
//

import Foundation
import HiveEngine

extension GameState {
	func json() -> String {
		let encoder = JSONEncoder()
		let data = try! encoder.encode(self)
		return String(data: data, encoding: .utf8)!
	}

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

	func evaluate() -> Int {
		let opponent = currentPlayer.next

		// Look for lose condition and set to min priority
		let hiveMindQueen = units.filter { $0.key.owner == currentPlayer && $0.key.class == .queen }.first!.key
		let hiveMindQueenSidesRemaining = exposedSides(of: hiveMindQueen)
		if hiveMindQueenSidesRemaining == 0 {
			return Int.min
		}

		// Look for win condition and set to max priority
		let opponentQueen = units.filter { $0.key.owner == opponent && $0.key.class == .queen }.first!.key
		let opponentQueenSidesRemaining = exposedSides(of: opponentQueen)
		if opponentQueenSidesRemaining == 0 {
			return Int.max
		}

		// Don't let the opponent shut you out
		if self.anyMovesAvailable(for: currentPlayer) == false {
			return Int.min + 1
		}

		var value = 0
		let hiveMindUnitsInPlay = unitsInPlay(for: currentPlayer) // 0 to 14
		hiveMindUnitsInPlay.forEach {
			value += $0.value(in: self)
		}

		let opponentUnitsInPlay = unitsInPlay.subtracting(hiveMindUnitsInPlay) // 0 to 14
		opponentUnitsInPlay.forEach {
			value += $0.value(in: self)
		}

		return value * (6 - opponentQueenSidesRemaining)

//		let opponentAvailableMoves = opponentMoves
//
//
//		let hiveMindPlayableSpaces = playableSpaces(for: currentPlayer)
//		let opponentPlayableSpaces = playableSpaces(for: opponent)
//
//
//		let hiveMindUnitsInPlay = unitsInPlay(for: currentPlayer) // 0 to 14
//		let opponentUnitsInPlay = unitsInPlay.subtracting(hiveMindUnitsInPlay) // 0 to 14
//
//		let hiveMindMoveableUnits = moveableUnits(for: currentPlayer)
//		let opponentMoveableUnits = moveableUnits(for: opponent)

//		return 0
	}

	private func unitsInPlay(for player: Player) -> Set<HiveEngine.Unit> {
		return unitsInPlay.filter { $0.owner == player }
	}

	private func moveableUnits(for player: Player) -> Set<HiveEngine.Unit> {
		return unitsInPlay(for: player).filter { $0.availableMoves(in: self).count > 0 }
	}

	private func exposedSides(of unit: HiveEngine.Unit) -> Int {
		return 6 - units(adjacentTo: unit).count
	}
}
