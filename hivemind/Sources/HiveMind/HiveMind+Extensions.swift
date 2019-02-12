//
//  HiveMind+Extensions.swift
//  HiveMind
//
//  Created by Joseph Roque on 2019-02-12.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveMindCore
import HiveMindEngine

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
