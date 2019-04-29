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
	private var ioProcessor: IOProcessor

	init(actor: HiveMind, ioProcessor: IOProcessor) {
		self.actor = actor
		self.ioProcessor = ioProcessor

		self.stateMachine = StateMachine(initialState: .launching, delegate: self)
	}

	/// Initialize the engine
	func start() {
		do {
			try ioProcessor.start(delegate: self)
		} catch {
			logger.write("Failed to start \(ioProcessor): \(error)")
		}

		do {
			try ioProcessor.run()
		} catch {
			logger.write("Error while runnnig \(ioProcessor): \(error)")
		}
	}

	fileprivate func dispatch(event: Event) {
		DispatchQueue.global().async {
			self.stateMachine.on(event: event)
		}
	}
}

extension Engine: IOProcessorDelegate {
	func handle(_ command: Command) {
		switch command {
		case .ready:
			dispatch(event: .initialized)
		case .exit:
			dispatch(event: .exited)
		case .quitGame:
			dispatch(event: .quit)
		case .movement(let movement):
			dispatch(event: .receivedInput(.movement(movement)))
		case .new(let options):
			dispatch(event: .receivedInput(.newGame(options)))
		case .play:
			dispatch(event: .receivedInput(.play))
		case .unknown:
			break
		}
	}
}

extension Engine: StateMachineDelegate {
	func didTransition(to: State, from: State, on: Event) {
		switch to {
		case .standby:
			if case .launching = from {
				break
			}
			actor.restart()
		case .exiting:
			ioProcessor.exit()
		case .exploring:
			let move = actor.play()
			dispatch(event: .bestMoveFound(move))
			ioProcessor.send(.movement(move))
		case .newGameStarting(let options):
			actor.options = options
			let event: Event = options.isFirst ? .becomingHiveMindTurn : .becomingOpponentTurn
			dispatch(event: event)
		case .playingMove(let movement):
			guard actor.apply(movement: movement) else {
				logger.error("Failed to apply move `\(movement)`")
				dispatch(event: .exited)
				return
			}

			if case .waitingForOpponent = from {
				ioProcessor.send(.success)
			}

			let event: Event = actor.isHiveMindCurrentPlayer ? .becomingHiveMindTurn : .becomingOpponentTurn
			dispatch(event: event)
		case .launching, .waitingForOpponent, .waitingToPlay:
			break
		}
	}

	func failedToHandle(event: Event) {
		if case .receivedInput(let input) = event {
			logger.debug("Failed to handle input: \(input.description)")
		}
	}
}
