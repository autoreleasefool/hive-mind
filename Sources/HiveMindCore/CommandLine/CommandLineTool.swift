//
//  CommandLineTool.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-12.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine
import Starscream

enum SocketMessage: CustomStringConvertible {
	case success
	case movement(Movement)
	case failure
	case invalidCommand

	var description: String {
		switch self {
		case .success: return "SUCCESS"
		case .failure: return "FAILED"
		case .invalidCommand: return "INVALID"
		case .movement(let movement): return movement.json()
		}
	}
}

public class CommandLineTool {
	private var isRunning: Bool = false
	private let configuration: Configuration
	private var socket: WebSocket!

	// AI actor
	var actor: Actor!

	public init() {
		self.configuration = Configuration(from: CommandLine.arguments)
	}

	/// Open the Websocket
	public func run() {
		isRunning = true
		socket = WebSocket(url: configuration.webSocketURL)
		socket.delegate = self
		socket.connect()
		logger.debug("HiveMind has initialized, listening on port \(configuration.port)")
	}

	/// Parse the given data as a string and respond to the command.
	private func parse(_ input: String?, completion: @escaping (SocketMessage) -> Void) {
		guard let input = input?.trimmingCharacters(in: .whitespacesAndNewlines) else {
			logger.error("No input provided.")
			completion(.invalidCommand)
			return
		}

		logger.debug("Parsing input: `\(input)`")

		let response: SocketMessage
		let command = input.prefix(upTo: input.firstIndex(of: " ") ?? input.endIndex)
		let value = extractValue(from: input)

		switch command {
		case "new", "n":
			if initHiveMind(value: value) {
				response = .success
			} else {
				response = .failure
			}
		case "move", "m":
			if let movement = parseMovement(value) {
				apply(movement: movement)
			}
			response = .success
		case "play":
			play { movement in
				completion(.movement(movement))
			}
			return
		case "exit":
			self.isRunning = false
			response = .success
		default:
			logger.debug("\(command) is not a valid command.")
			response = .invalidCommand
		}

		completion(response)
	}

	private func extractValue(from input: String) -> String {
		let preIndex = input.firstIndex(of: " ") ?? input.index(before: input.endIndex)
		return String(input.suffix(from: input.index(after: preIndex)))
	}

	// MARK: Commands

	/// Create a new HiveMind
	private func initHiveMind(value: String) -> Bool {
		let config = value.split(separator: " ")
		let isFirst = Bool(String(config.first ?? "")) ?? true
		let explorationTime: TimeInterval = Double(config.last ?? "") ?? 10

		let options = HiveMind.Options(minExplorationTime: explorationTime)
		do {
			actor = try HiveMind(isFirst: isFirst, options: options)
			logger.debug("Initialized HiveMind with: \(isFirst), \(explorationTime)")
			return true
		} catch {
			logger.error(error: error, "Failed to create HiveMind")
			return false
		}
	}

	/// Parse a `Movement` from a `String`
	private func parseMovement(_ raw: String) -> Movement? {
		let json = raw.trimmingCharacters(in: .whitespacesAndNewlines)
		guard json.isEmpty == false else {
			logger.error("<Movement> was empty.")
			return nil
		}

		let decoder = JSONDecoder()
		guard let data = json.data(using: .utf8), let movement = try? decoder.decode(Movement.self, from: data) else {
			logger.error("<Movement> was not valid.")
			return nil
		}

		return movement
	}

	/// Pass a `Movement` to the HiveMind
	private func apply(movement: Movement) {
		actor.apply(movement: movement)
	}

	/// Print the current best move from the HiveMind
	private func play(completion: @escaping (Movement) -> Void) {
		actor.play(completion: completion)
	}

	/// Send some data to the Socket
	private func writeToSocket(message: SocketMessage) {
		socket.write(string: message.description)
	}
}

extension CommandLineTool: WebSocketDelegate {
	public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		logger.debug("WebSocket received some Data: \(data.count) elements.")
		if let input = String(data: data, encoding: .utf8) {
			parse(input) { [weak self] message in
				self?.writeToSocket(message: message)
			}
		} else {
			logger.error("Failed to decode Data as String.")
		}
	}

	public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		logger.debug("WebSocket recieved some Text: \(text.count) characters.")
		parse(text) { [weak self] message in
			self?.writeToSocket(message: message)
		}
	}

	public func websocketDidConnect(socket: WebSocketClient) {
		logger.debug("Connection to WebSocket opened.")
	}

	public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		if let error = error as? WSError {
			logger.error(error.message, "Connection to WebSocket closed.")
		} else if let error = error {
			logger.error(error: error, "Connection to WebSocket closed.")
		} else {
			logger.error("Connection to WebSocket closed.")
		}
	}
}
