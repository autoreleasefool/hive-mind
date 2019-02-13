//
//  CommandLineTool.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-12.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

public final class CommandLineTool {
	private let arguments: [String]

	public init(arguments: [String] = CommandLine.arguments) {
		self.arguments = arguments
	}

	public func run() throws {
		let hivemind: HiveMind
		if arguments.count > 1,
			let jsonHivemind = try? HiveMind(fromJSON: arguments[1]) {
			hivemind = jsonHivemind
		} else {
			hivemind = HiveMind()
		}

		print(hivemind.playJSON())
	}
}
