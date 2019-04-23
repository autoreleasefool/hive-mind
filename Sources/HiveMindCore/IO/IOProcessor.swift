//
//  IOProcessor.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-22.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

/// Class which processes the input to the HiveMind and drives its interactions
protocol IOProcessor: class {
	/// Start listening for input
	func start() throws
	/// Wait indefinitely until input is no longer available
	func run() throws
	/// Send a response
	func send(_ output: Output)
}
