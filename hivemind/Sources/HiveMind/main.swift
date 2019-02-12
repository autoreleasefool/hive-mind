//
//  main.swift
//  HiveMind
//
//  Created by Joseph Roque on 2019-02-11.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveMindCore

let hivemind: HiveMind
print(CommandLine.arguments)
if CommandLine.arguments.count > 1,
	let jsonHivemind = try? HiveMind(fromJSON: CommandLine.arguments[1]) {
	hivemind = jsonHivemind
} else {
	hivemind = HiveMind()
}

print(hivemind.playJSON())
