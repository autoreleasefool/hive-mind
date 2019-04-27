//
//  IOProcessor.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-22.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

/// Delegate to handle input
protocol IOProcessorDelegate: class {
	/// Handle the commands from the input
	func handle(_ command: Command)
}

/// Class which processes the input to the HiveMind and drives its interactions
protocol IOProcessor: class {
	/// Start listening for input
	func start(delegate: IOProcessorDelegate) throws
	/// Wait indefinitely until input is no longer available
	func run() throws
	/// Send a response
	func send(_ output: Output)
}

