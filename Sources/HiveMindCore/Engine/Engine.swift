//
//  Engine.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-22.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

class Engine {

	/// AI actor
	private let actor: HiveMind

	/// State Machine
	private var stateMachine: StateMachine<State, Event, Engine>!

	/// Send messages
	private weak var ioProcessor: IOProcessor?

	init(actor: HiveMind, ioProcessor: IOProcessor) {
		self.actor = actor
		self.ioProcessor = ioProcessor

		self.stateMachine = StateMachine(initialState: .launching, delegate: self)
	}

	/// Handle input commands and delegate to the HiveMind appropriately
	///
	/// - Parameters:
	///   - command: the command to handle
	func handle(_ command: Command) {
		switch command {
		case .exit:
			stateMachine.on(event: .exited)
		case .movement(let movement):
			stateMachine.on(event: .receivedInput(.movement(movement)))
		case .new(let options):
			stateMachine.on(event: .receivedInput(.newGame(options)))
		case .play:
			stateMachine.on(event: .receivedInput(.play))
		case .unknown:
			break
		}
	}
}

extension Engine: StateMachineDelegate {
	func didTransition(to: State, from: State, on: Event) {
		switch to {
		case .exiting:
			actor.exit()
		case .exploring:
			actor.play { [weak self] in
				self?.stateMachine.on(event: .bestMoveFound($0))
				self?.ioProcessor?.send(.movement($0))
			}
		case .newGameStarting(let options):
			actor.options = options
		case .playingMove(let movement):
			actor.apply(movement: movement)
			let event: Event = actor.isHiveMindCurrentPlayer ? .becomingHiveMindTurn : .becomingOpponentTurn
			stateMachine.on(event: event)
		case .launching, .standby, .waitingForOpponent, .waitingToPlay:
			break
		}
	}

	func failedToHandle(event: Event) {
		if case .receivedInput(let input) = event {
			logger.debug("Failed to handle input: \(input.description)")
		}
	}
}
