//
//  Engine+State.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-23.
//

import HiveEngine

extension Engine {
	enum State: StateMachineState {
		case launching
		case standby
		case newGameStarting(HiveMind.Options)
		case waitingToPlay
		case exploring
		case playingMove(Movement)
		case waitingForOpponent
		case exiting

		// swiftlint:disable cyclomatic_complexity function_body_length
		// Explicitly handling each state + event for clarity. Flow is explained below.

		func handle(event: Engine.Event) -> Engine.State? {
			switch (self, event) {
			// Always exit when exit event is received
			case (_, .exited):
				return .exiting
			case (.exiting, _):
				return nil

			// Can only transition launching -> standby
			case (.launching, .initialized):
				return .standby
			case (.launching, _), (_, .initialized):
				return nil

			// Can only transition standby -> newGameStarting
			case (.standby, .receivedInput(.newGame(let options))):
				return .newGameStarting(options)
			case (.standby, _), (_, .receivedInput(.newGame)):
				return nil

			// Can only transition newGameStarting -> HiveMind's turn or Opponent's turn
			case (.newGameStarting, .becomingHiveMindTurn):
				return .waitingToPlay
			case (.newGameStarting, .becomingOpponentTurn):
				return .waitingForOpponent
			case (.newGameStarting, _):
				return nil

			// Can only transition waitingToExplore -> exploring
			case (.waitingToPlay, .receivedInput(.play)):
				return .exploring
			case (.waitingToPlay, _), (_, .receivedInput(.play)):
				return nil

			// Can only transition exploring -> playingMove or exiting
			case (.exploring, .bestMoveFound(let movement)):
				return .playingMove(movement)
			case (.exploring, .gameEnded):
				return .exiting
			case (.exploring, _), (_, .bestMoveFound):
				return nil

			// Can only transition waitingForOpponent -> playingMove or exiting
			case (.waitingForOpponent, .receivedInput(.movement(let movement))):
				return .playingMove(movement)
			case (.waitingForOpponent, .gameEnded):
				return .exiting
			case (.waitingForOpponent, _), (_, .receivedInput(.movement)):
				return nil

			// Transition to waiting based on move played
			case (.playingMove, .becomingHiveMindTurn):
				return .waitingToPlay
			case (.playingMove, .becomingOpponentTurn):
				return .waitingForOpponent
			case (.playingMove, _), (_, .becomingHiveMindTurn), (_, .becomingOpponentTurn):
				return nil
			}
		}

		// swiftlint:enable cyclomatic_complexity, function_body_length
	}

	enum Event: StateMachineEvent {
		case initialized
		case receivedInput(Engine.Input)
		case bestMoveFound(Movement)
		case gameEnded([Player])
		case becomingHiveMindTurn
		case becomingOpponentTurn
		case exited

		var description: String {
			switch self {
			case .initialized: return "[Initialized]"
			case .receivedInput(let input): return "[Input] \(input)"
			case .bestMoveFound(let movement): return "[Best Move] \(movement)"
			case .becomingHiveMindTurn: return "[HiveMind Turn]"
			case .becomingOpponentTurn: return "[Opponent Turn]"
			case .gameEnded(let winners): return "[Game End] Winner(s): \(winners)"
			case .exited: return "[Exit]"
			}
		}
	}

	enum Input: CustomStringConvertible {
		case newGame(HiveMind.Options)
		case movement(Movement)
		case play

		var description: String {
			switch self {
			case .newGame(let options): return "[New Game] \(options.isFirst)"
			case .movement(let movement): return "[Movement] \(movement)"
			case .play: return "[Play]"
			}
		}

		/// Parse a `Command` and return a valid `Input` for the HiveMind
		static func from(command: Command) -> Input? {
			switch command {
			case .movement(let movement): return .movement(movement)
			case .play: return .play
			case .new(let options): return .newGame(options)
			case .exit, .unknown, .ready: return nil
			}
		}
	}
}
