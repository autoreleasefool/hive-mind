//
//  HiveMind.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveMindEngine

public class HiveMind {

	private let state: GameState

	public init(state: GameState) {
		self.state = state
	}

	public func play() -> Movement {
		let moves = state.availableMoves
		let selectedMove = Int.random(in: 0..<moves.count)
		return moves[selectedMove]
	}
}
