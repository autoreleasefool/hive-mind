//
//  Core.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-23.
//

import Foundation

public struct Core {

	/// Initialize the HiveMindCore module
	public static func run() throws {
		var parser = ArgumentParser(name: "HiveMind", description: "An AI created to play the game Hive.")
		var arguments: Arguments?
		do {
			try parser.add(
				arg: "enableCmd",
				ofType: .flag,
				description: "Accept input through the Command Line"
			)

			try parser.add(
				arg: "port",
				ofType: .int,
				description: "Port number to run WebSocket on. Ignored when `enableCmd` flag is provided",
				defaultValue: .int(Server.Configuration.DefaultPortNumber)
			)

			try parser.add(
				arg: "time",
				ofType: .double,
				description: "Maximum amount of time the HiveMind should explore",
				defaultValue: .double(10.0)
			)

			arguments = try parser.parse(Array(CommandLine.arguments.dropFirst()))
		} catch {
			logger.write("Failed to parse arguments: \(error.localizedDescription)")
			logger.write(parser.help())
			logger.write("Exiting...")
		}

		if let args = arguments {
			let actor = HiveMind()

			let processor: IOProcessor
			if args.isFlagPresent(flag: "enableCmd") {
				processor = CommandLineTool(actor: actor)
			} else {
				let portValue = args.argumentValue(of: "port", as: Int.self)!
				let configuration = Server.Configuration(port: portValue)
				processor = try Server(configuration: configuration, actor: actor)
			}

			let engine = Engine(actor: actor, ioProcessor: processor)
			engine.start()
		}

	}

}
