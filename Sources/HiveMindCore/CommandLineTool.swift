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
	private var isRunning: Bool = false

	var hiveMind: HiveMind!

	public init() {}

	/// Start the process
	public func run() {
		self.isRunning = true
		logger.debug("HiveMind has initialized.")
		printOptions()
		waitForInput()
	}

	/// Print the available commands
	private func printOptions() {
		logger.debug(
			"Options:",
			"\tnew, n <bool>: start a new game. Boolean determines if the HiveMind is first (true) or second (false)",
			"\tmove, m <Movement>: parse the movement and provides a Movement response in return",
			"\tplay: return the best move, applies it to the current state and continues exploration",
			"\texit: exit the tool",
			separator: "\n"
		)
	}

	/// Starts a background thread to wait for command line input.
	private func waitForInput() {
		logger.debug("Waiting for input...")

		let data = FileHandle.standardInput.availableData
		guard let input = String(data: data, encoding: .utf8) else {
			logger.debug("Failed to retrieve input.")

			if isRunning {
				waitForInput()
			}
			return
		}

		parse(input)
		if isRunning {
			waitForInput()
		} else {
			logger.debug("Goodbye!")
		}
	}

	/// Parse the given data as a string and respond to the command.
	private func parse(_ input: String?) {
		guard let input = input?.trimmingCharacters(in: .whitespacesAndNewlines) else {
			logger.error("No input provided.")
			return
		}

		logger.debug("Parsing input: `\(input)`")

		let command = input.prefix(upTo: input.firstIndex(of: " ") ?? input.endIndex)

		switch command {
		case "new", "n":
			if let isFirst = Bool(extractValue(from: input)) {
				initHiveMind(isFirst: isFirst)
			} else {
				logger.error("Failed to create HiveMind")
			}
		case "move", "m":
			if let movement = parseMovement(extractValue(from: input)) {
				respondTo(move: movement)
			}
		case "play":
			play()
		case "exit":
			self.isRunning = false
		default:
			logger.debug("\(command) is not a valid command.")
			printOptions()
		}
	}

	private func extractValue(from input: String) -> String {
		let preIndex = input.firstIndex(of: " ") ?? input.index(before: input.endIndex)
		return String(input.suffix(from: input.index(after: preIndex)))
	}

	// MARK: Commands

	/// Create a new HiveMind
	private func initHiveMind(isFirst: Bool) {
		do {
			hiveMind = try HiveMind(isFirst: isFirst)
		} catch {
			logger.error(error: error, "Failed to create HiveMind")
		}
	}

	/// Parse a `Movement` from a `String`
	private func parseMovement(_ raw: String) -> Movement? {
		let json = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		guard json.isEmpty == false else {
			logger.error("<Movement> was empty.")
			return nil
		}

		let decoder = JSONDecoder()
		guard let data = json.data(using: .utf8), let movement = try? decoder.decode(Movement.self, from: data) else {
			logger.error("<Movement> was not valid.")
			return nil
		}

		return movement
	}

	/// Pass a `Movement` to the HiveMind and print a `Movement` in response
	private func respondTo(move: Movement) {
		hiveMind.apply(movement: move)
	}

	/// Print the current best move from the HiveMind
	private func play() {
		hiveMind.play { logger.log($0.json()) }
	}
}
