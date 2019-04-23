//
//  CommandLineTool.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-12.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

class CommandLineTool: IOProcessor {
	/// True while the tool is running, false once it stops
	private var isRunning: Bool = false

	/// AI actor
	private let actor: Actor

	/// Handle inputs and outputs from the HiveMind
	private var engine: Engine!

	init(actor: Actor) {
		self.actor = actor
	}

	// MARK: - IOProcessor

	func start() throws {
		self.engine = Engine(actor: actor, ioProcessor: self)
	}

	func run() throws {
		isRunning = true
		waitForInput()
	}

	func send(_ output: Output) {
		logger.log(output.description)
	}

	// MARK: - Private

	/// Wait for input from STDIN and parse the input provided. Loops until `isRunning` is false
	private func waitForInput() {
		while isRunning {
			let input = readLine()
			let command = parse(input)
			engine.handle(command)
			handle(command)
		}

		logger.debug("Exiting...")
	}

	/// Parse the input from STDIN and return a `Command`
	private func parse(_ text: String?) -> Command {
		guard let input = text?.trimmingCharacters(in: .whitespacesAndNewlines), input.isEmpty == false else {
			logger.error("No input provided.")
			return .unknown
		}

		logger.debug("Parsing input: `\(input)`")

		let rawCommand = String(input.prefix(upTo: input.firstIndex(of: " ") ?? input.endIndex))
		var values: [String]?

		if let firstSpace = input.firstIndex(of: " ") {
			values = String(input.suffix(from: input.index(after: firstSpace))).split(separator: " ").map { String($0) }
		}

		return Command.from(command: rawCommand, withValues: values)
	}

	/// Handle commands appropriately
	private func handle(_ command: Command) {
		switch command {
		case .exit:
			isRunning = false
		case .movement, .new, .play, .unknown:
			break
		}
	}
}
