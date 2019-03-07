//
//  Unit+Extensions.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-03.
//

import HiveEngine

extension Unit {
	func value(in state: GameState) -> Int {
		// Prevent playing queen on the first move
		if state.move <= 1 && self.class == .queen { return 0 }

		let isMobile = self.availableMoves(in: state).count > 0
		let value = isMobile ? basicValue : basicValue / 2
		return owner == state.currentPlayer ? value : -value
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
