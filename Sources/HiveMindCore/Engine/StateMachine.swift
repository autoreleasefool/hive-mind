//
//  StateMachine.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-20.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

/// Possible state-altering events
protocol StateMachineEvent: CustomStringConvertible { }

/// Valid states for the `StateMachine`
protocol StateMachineState {
	associatedtype Event

	/// Handle an `Event` and return a new state if the event was accepted, or nil if the event was invalid.
	func handle(event: Event) -> Self?
}

/// Delegate protocol for `StateMachine` callbacks
protocol StateMachineDelegate: class {
	associatedtype State
	associatedtype Event

	/// Invoked when the `StateMachine` successfully transitions to a new state after the given event
	///
	/// - Parameters:
	///   - to: the new state
	///   - from: the old state
	///   - on: the event which caused the transition
	func didTransition(to: State, from: State, on: Event)

	/// Invoked when an `Event` fails to affect the current state
	///
	/// - Parameters:
	///   - event: the failed event
	func failedToHandle(event: Event)
}

/// Manage the current state and valid transitions.
struct StateMachine<State: StateMachineState, Event: StateMachineEvent, Delegate: StateMachineDelegate> where State.Event == Event, Delegate.Event == Event, Delegate.State == State {
	private(set) var state: State
	private weak var delegate: Delegate?

	init(initialState: State, delegate: Delegate) {
		logger.debug("[State Machine] initial state is \(initialState)")
		self.state = initialState
		self.delegate = delegate
	}

	mutating func on(event: Event) {
		let originalState = self.state
		guard let newState = state.handle(event: event) else {
			logger.debug("Failed to handle \(event), state is \(state)")
			delegate?.failedToHandle(event: event)
			return
		}

		self.state = newState
		logger.debug("Transitioning \(originalState) -> \(state)")
		delegate?.didTransition(to: state, from: originalState, on: event)
	}
}
