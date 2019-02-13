//
//  HiveMind.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveMindEngine

class HiveMind {

	private let state: GameState

	init(state: GameState) {
		self.state = state
	}

	func play() -> Movement {
		let moves = state.availableMoves
		let selectedMove = Int.random(in: 0..<moves.count)
		return moves[selectedMove]
	}
}

// MARK: - JSON I/O

extension HiveMind {
	convenience init() {
		let state = GameState()
		self.init(state: state)
	}

	convenience init(fromJSON jsonString: String) throws {
		let jsonData = jsonString.data(using: .utf8)!
		let decoder = JSONDecoder()

		let state = try decoder.decode(GameState.self, from: jsonData)
		self.init(state: state)
	}

	func playJSON() -> String {
		let movement = self.play()
		let encoder = JSONEncoder()
		do {
			let data = try encoder.encode(movement)
			return String.init(data: data, encoding: .utf8)!
		} catch {
			return ""
		}
	}
}
