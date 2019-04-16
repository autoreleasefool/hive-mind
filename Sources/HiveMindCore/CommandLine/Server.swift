//
//  Server.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-14.
//

import HiveEngine
import WebSocket

protocol ServerDelegate: class {
	func serverDidReceiveResponse(server: Server, response: SocketResponse)
	func serverDidDisconnect(server: Server)
}

private struct EchoResponder: HTTPServerResponder {
	func respond(to request: HTTPRequest, on worker: Worker) -> EventLoopFuture<HTTPResponse> {
		let response = HTTPResponse(body: request.body)
		return worker.eventLoop.newSucceededFuture(result: response)
	}
}

class Server {

	private weak var delegate: ServerDelegate?

	/// Primary HTTPServer
	private var server: HTTPServer!

	/// Server WebSocket connection
	private var socket: WebSocket!

	/// Worker that server events will be handled with.
	private var group: EventLoopGroup!

	init(hostname: String, port: Int, delegate: ServerDelegate) throws {
		self.delegate = delegate

		let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: { [weak self] req in
			// Only upgrade a connection if there isn't already another open connection
			guard self?.socket == nil else { return nil }
			logger.debug("Connection to WebSocket opened.")
			return [:]
			}, onUpgrade: { [weak self] socket, _ in
				self?.socket = socket

				socket.onText() { [weak self] ws, text in
					guard let self = self else { return }
					let response = self.parse(text)
					self.delegate?.serverDidReceiveResponse(server: self, response: response)
				}
			})

		self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

		self.server = try HTTPServer.start(
			hostname: hostname,
			port: port,
			responder: EchoResponder(),
			upgraders: [ws],
			on: group,
			onError: { error in
				logger.error("Error in WebSocket: \(error)")
			}).wait()

		logger.debug("HiveMind has initialized, listening on port \(port)")
	}

	/// Send a message across the socket.
	func send(_ message: SocketMessage) {
		socket.send(message.description)
	}

	/// Waits for the socket to close before returning.
	func wait() throws {
		try server.onClose.wait()
	}

	/// Close the WebSocket
	func exit() {
		socket.close()
	}

	/// Handle a response from the WebSocket connection and call appropriate delegate methods.
	private func parse(_ text: String) -> SocketResponse {
		let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard input.isEmpty == false else {
			logger.error("No input provided.")
			return .unknown
		}

		logger.debug("Parsing input: `\(input)`")

		let command = String(input.prefix(upTo: input.firstIndex(of: " ") ?? input.endIndex))
		var values: [String]? = nil

		if let firstSpace = input.firstIndex(of: " ") {
			values = String(input.suffix(from: input.index(after: firstSpace))).split(separator: " ").map { String($0) }
		}

		return SocketResponse.from(command: command, withValues: values)
	}
}

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

enum SocketResponse {
	case new(HiveMind.Options)
	case play
	case movement(Movement)
	case exit
	case unknown

	/// Parse a `String` and return the corresponding `SocketResponse`
	static func from(command: String, withValues values: [String]?) -> SocketResponse {
		switch command {
		case "play":
			return .play
		case "exit":
			return .exit
		case "new", "n":
			return SocketResponse.new(from: values)
		case "move", "m":
			return SocketResponse.movement(from: values)
		default:
			return .unknown
		}
	}

	/// Parse a `.new` `SocketResponse` from the given values
	private static func new(from values: [String]?) -> SocketResponse {
		if let firstValue = values?.first, let isFirst = Bool(firstValue) {
			if let secondValue = values?.dropFirst().first, let explorationTime = Double(secondValue) {
				return .new(HiveMind.Options(isFirst: isFirst, minExplorationTime: explorationTime))
			} else {
				return .new(HiveMind.Options(isFirst: isFirst))
			}
		}

		return .new(HiveMind.Options())
	}

	/// Parse a `.move` `SocketResponse` from the given values, or return `.unknown` if the values are invalid
	private static func movement(from values: [String]?) -> SocketResponse {
		let decoder = JSONDecoder()
		if let firstValue = values?.first, let data = firstValue.data(using: .utf8), let movement = try? decoder.decode(Movement.self, from: data) {
			return .movement(movement)
		}

		return .unknown
	}
}
