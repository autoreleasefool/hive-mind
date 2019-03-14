//
//  CacheableGameState.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-06.
//

import HiveEngine

extension Position {
	var cacheableDescription: String {
		return "\(x),\(y),\(z)"
	}
}

extension Unit {
	var cacheableDescription: String {
		var description = self.owner == .white ? "W" : "B"
		switch self.class {
		case .ant: description.append("A")
		case .beetle: description.append("B")
		case .hopper: description.append("H")
		case .ladyBug: description.append("L")
		case .mosquito: description.append("M")
		case .pillBug: description.append("P")
		case .queen: description.append("Q")
		case .spider: description.append("S")
		}
		return description
	}
}

struct CacheableGameState {
	let rawValue: String

	init(from state: GameState) {
		var value = ""
		for stack in state.stacks.sorted(by: { s1, s2 in s1.key < s2.key }) {
			value.append(contentsOf: stack.key.cacheableDescription)
			value.append(":")
			for unit in stack.value {
				value.append(contentsOf: unit.cacheableDescription)
				value.append(",")
			}
		}

		self.rawValue = value
	}
}

extension GameState {
	var cacheable: CacheableGameState {
		return CacheableGameState(from: self)
	}
}
