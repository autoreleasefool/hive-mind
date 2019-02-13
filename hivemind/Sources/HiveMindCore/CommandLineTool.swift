//
//  CommandLineTool.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-12.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

public final class CommandLineTool {
	private let arguments: [String]

	public init(arguments: [String] = CommandLine.arguments) {
		self.arguments = Array(arguments.dropFirst())
	}

	public func run() throws {
		guard arguments.count > 0 else {
			print("No arguments provided.")
			return
		}

		if arguments.count == 1 {
			parseArgument(arguments[0])
		} else if arguments.count == 2 {
			parseArgument(arguments[0], withValue: arguments[1])
		} else if arguments.count == 3 {
			parseArgument(arguments[0], withValues: [arguments[1], arguments[2]])
		} else {
			print("Invalid arguments.")
		}
	}

	private func parseArgument(_ argument: String) {
		switch argument {
		case "-h", "--help":
			print("""
			Welcome to the HiveMind. Usage:
				--new
					Print a new state.
				--play <state>
					Print a valid play for the given state.
				--apply <move> <state>
					Apply a given move to a given state and print the resulting state.
				--moves <state>
					Print all valid moves for the given state.
			""")
		case "--new":
			let hivemind = HiveMind()
			print(hivemind.stateJSON())
		default:
			print("Invalid arguments.")
		}
	}

	private func parseArgument(_ argument: String, withValue value: String) {
		switch argument {
		case "--play":
			if let hivemind = try? HiveMind(fromJSON: value) {
				print(hivemind.playJSON())
			}
		case "--moves":
			if let hivemind = try? HiveMind(fromJSON: value) {
				print(hivemind.movesJSON())
			}
		default:
			print("Invalid arguments.")
		}
	}

	private func parseArgument(_ argument: String, withValues values: [String]) {
		switch argument {
		case "--apply":
			if let hivemind = try? HiveMind(fromJSON: values[0]),
				let moveData = values[1].data(using: .utf8),
				let move = try? JSONDecoder().decode(Movement.self, from: moveData) {
				hivemind.apply(move)
				print(hivemind.stateJSON())
			}
		default:
			print("Invalid arguments.")
		}
	}
}
