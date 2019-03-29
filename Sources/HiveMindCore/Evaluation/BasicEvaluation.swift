//
//  BasicEvaluation.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-27.
//

import HiveEngine

struct BasicEvaluation {
	/// Basic material evaluation.
	static func eval(state: GameState, with support: GameStateSupport) -> Int {
		let opponent = state.currentPlayer.next

		let playerQueen: HiveEngine.Unit
		let opponentQueen: HiveEngine.Unit
		switch state.currentPlayer {
		case .white:
			playerQueen = support.whiteQueen
			opponentQueen = support.blackQueen
		case .black:
			playerQueen = support.blackQueen
			opponentQueen = support.whiteQueen
		}

		// Look for lose condition and set to min priority
		let playerQueenSidesRemaining = state.exposedSides(of: playerQueen)
		if playerQueenSidesRemaining == 0 {
			return Int.min
		}

		// Look for win condition and set to max priority
		let opponentQueenSidesRemaining = state.exposedSides(of: opponentQueen)
		if opponentQueenSidesRemaining == 0 {
			return Int.max
		}

		// Don't let the opponent shut you out
		if state.anyMovesAvailable(for: state.currentPlayer) == false {
			return Int.min + 1
		}

		// Evaluate the board based on the number of pieces available and moveable
		var value = 0
		state.unitsInPlay[state.currentPlayer]!.forEach {
			value += $0.key.absoluteBasicValue(in: state)
		}

		state.unitsInPlay[opponent]!.forEach {
			value -= $0.key.absoluteBasicValue(in: state)
		}

		return value * (6 - opponentQueenSidesRemaining)
	}
}

extension Unit {
	fileprivate func absoluteBasicValue(in state: GameState) -> Int {
		// Prevent playing queen on the first move
		if state.move <= 1 && self.class == .queen { return 0 }

		let isMobile = self.availableMoves(in: state).count > 0
		return isMobile ? basicValue : basicValue / 2
	}

	var basicValue: Int {
		switch self.class {
		case .ant: return 80
		case .beetle: return 80
		case .hopper: return 40
		case .ladyBug: return 50
		case .mosquito: return 75
		case .pillBug: return 60
		case .queen: return 100
		case .spider: return 20
		}
	}
}

