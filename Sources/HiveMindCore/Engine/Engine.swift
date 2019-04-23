//
//  Engine.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-22.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

struct Engine {

	/// AI actor
	private let actor: Actor

	/// Send messages
	private weak var ioProcessor: IOProcessor?

	init(actor: Actor, ioProcessor: IOProcessor) {
		self.actor = actor
		self.ioProcessor = ioProcessor
	}

	/// Handle input commands and delegate to the HiveMind appropriately
	func handle(_ command: Command) {

	}
}
