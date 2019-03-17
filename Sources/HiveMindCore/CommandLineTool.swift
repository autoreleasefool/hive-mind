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
			logger.log("No arguments provided.")
			return
		}

		if arguments.count == 1 {
			parseArgument(arguments[0])
		} else if arguments.count == 2 {
			parseArgument(arguments[0], withValue: arguments[1])
		} else {
			logger.log("Invalid arguments.")
		}
	}

	private func parseArgument(_ argument: String) {
		switch argument {
		case "-h", "--help":
			logger.log("""
			Welcome to the HiveMind. Usage:
				--new
					Print a new state.
				--play <state>
					Print a valid play for the given state.
			""")
		case "--new":
			guard let hivemind = try? HiveMind() else { return }
			logger.log(hivemind.state.json())
		default:
			logger.log("Invalid arguments.")
		}
	}

	private func parseArgument(_ argument: String, withValue value: String) {
		switch argument {
		case "--play":
			if let hivemind = try? HiveMind(fromJSON: value) {
				logger.log(hivemind.play().json())
			}
		default:
			logger.log("Invalid arguments.")
		}
	}
}
