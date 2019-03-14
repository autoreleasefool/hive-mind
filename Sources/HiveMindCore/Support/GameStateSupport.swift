//
//  GameStateSupport.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-13.
//

import HiveEngine

struct GameStateSupport {

	let whiteQueen: HiveEngine.Unit
	let blackQueen: HiveEngine.Unit

	init(state: GameState) {
		whiteQueen = state.unitsInPlay[Player.white]?.first { $0.key.class == .queen }?.key ??
			state.unitsInHand[Player.white]!.first { $0.class == .queen }!
		blackQueen = state.unitsInPlay[Player.black]?.first { $0.key.class == .queen }?.key ??
			state.unitsInHand[Player.black]!.first { $0.class == .queen}!
	}

}
