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
		logger.log("HiveMind has initialized.")
		printOptions()
		waitForInput()
	}

	/// Print the available commands
	private func printOptions() {
		logger.log(
			"Options:",
			"\t--new, -n <bool>: start a new game. Boolean determines if the HiveMind is first (true) or second (false)",
			"\t--move, -m <Movement>: parse the movement and provides a Movement response in return",
			"\t--play: return the best move, applies it to the current state and continues exploration",
			"\t--exit: exit the tool",
			separator: "\n"
		)
	}

	/// Starts a background thread to wait for command line input.
	private func waitForInput() {
		logger.log("Waiting for input...")
		parse(readLine())
		if isRunning {
			waitForInput()
		} else {
			logger.log("Goodbye!")
		}
	}

	/// Parse the given data as a string and respond to the command.
	private func parse(_ input: String?) {
		guard let input = input else {
			logger.error("No input provided.")
			return
		}

		let command = input.prefix(upTo: input.firstIndex(of: " ") ?? input.endIndex)

		switch command {
		case "--new", "-n":
			initHiveMind()
		case "--move", "-m":
			if let movement = parseMovement(String(input.suffix(from: input.firstIndex(of: " ") ?? input.endIndex))) {
				respondTo(move: movement)
			}
		case "--play":
			play()
		case "--exit":
			self.isRunning = false
		default:
			logger.log("\(command) is not a valid command.")
			printOptions()
		}
	}

	// MARK: Commands

	/// Create a new HiveMind
	private func initHiveMind() {
		do {
			hiveMind = try HiveMind()
		} catch {
			logger.error(error: error, "Failed to create HiveMind")
		}
	}

	/// Parse a `Movement` from a `String`
	private func parseMovement(_ raw: String) -> Movement? {
		let json = raw.trimmingCharacters(in: .whitespaces)
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
		play()
	}

	/// Print the current best move from the HiveMind
	private func play() {
		hiveMind.play { logger.log($0.json()) }
	}
}
