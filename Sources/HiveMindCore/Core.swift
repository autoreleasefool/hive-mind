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
				arg: "server",
				ofType: .flag,
				description: "Accept input through a WebSocket"
			)

			try parser.add(
				arg: "port",
				ofType: .int,
				description: "Port number to run WebSocket on",
				defaultValue: Server.Configuration.DefaultPortNumber
			)

			try parser.add(
				arg: "time",
				ofType: .double,
				description: "Maximum amount of time the HiveMind should explore",
				defaultValue: 10.0
			)

			arguments = try parser.parse(CommandLine.arguments)
		} catch {
			print("Failed to parse arguments: \(error.localizedDescription)")
			print("Exiting...")
		}

		func start(_ ioProcessor: IOProcessor) {
			do {
				try ioProcessor.start()
			} catch {
				print("Failed to start \(ioProcessor): \(error)")
			}

			do {
				try ioProcessor.run()
			} catch {
				print("Error while runnnig \(ioProcessor): \(error)")
			}
		}

		if let args = arguments {
			let actor = HiveMind()

			if args.isFlagPresent(flag: "server") {
				let portValue = args.argumentValue(of: "port", as: Int.self)!
				let configuration = Server.Configuration(port: portValue)
				let server = try Server(configuration: configuration, actor: actor)
				start(server)
			} else {
				let tool = CommandLineTool(actor: actor)
				start(tool)
			}
		}

	}

}
