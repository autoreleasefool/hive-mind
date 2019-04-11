//
//  Configuration.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-11.
//

import Foundation

struct Configuration {

	private static let DEFAULT_PORT = 8081

	/// The port on which the HiveMind will listen
	let port: Int

	init(from arguments: [String]) {
		var port: Int?

		for (index, argument) in arguments.enumerated() {
			switch argument {
			case "--port", "-p":
				port = Configuration.parsePort(from: arguments, at: index + 1)
			default:
				break
			}
		}

		self.port = port ?? Configuration.DEFAULT_PORT
	}

	var webSocketURL: URL {
		return URL(string: "ws://localhost:\(port)")!
	}

	private static func parsePort(from args: [String], at index: Int) -> Int? {
		guard index < args.count else { return nil }
		return Int(args[index])
	}
}
