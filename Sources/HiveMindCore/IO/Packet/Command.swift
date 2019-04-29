//
//  Command.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-22.
//

import Foundation
import HiveEngine

enum Command {
	case ready
	case new(HiveMind.Options)
	case play
	case movement(Movement)
	case exit
	case quitGame
	case unknown

	/// Parse a `String` and return the corresponding `Command`
	static func from(command: String, withValues values: [String]?) -> Command {
		switch command {
		case "play":
			return .play
		case "exit":
			return .exit
		case "new", "n":
			return Command.new(from: values)
		case "move", "m":
			return Command.movement(from: values)
		case "quit":
			return .quitGame
		default:
			return .unknown
		}
	}

	/// Parse a `.new` `Command` from the given values
	private static func new(from values: [String]?) -> Command {
		if let firstValue = values?.first, let isFirst = Bool(firstValue) {
			if let secondValue = values?.dropFirst().first, let explorationTime = Double(secondValue) {
				return .new(HiveMind.Options(isFirst: isFirst, maxExplorationTime: explorationTime))
			} else {
				return .new(HiveMind.Options(isFirst: isFirst))
			}
		}

		return .new(HiveMind.Options())
	}

	/// Parse a `.move` `Command` from the given values, or return `.unknown` if the values are invalid
	private static func movement(from values: [String]?) -> Command {
		let decoder = JSONDecoder()
		if let firstValue = values?.first, let data = firstValue.data(using: .utf8), let movement = try? decoder.decode(Movement.self, from: data) {
			return .movement(movement)
		}

		return .unknown
	}
}
