//
//  Server.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-14.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import HiveEngine
import WebSocket

private struct EchoResponder: HTTPServerResponder {
	func respond(to request: HTTPRequest, on worker: Worker) -> EventLoopFuture<HTTPResponse> {
		let response = HTTPResponse(body: request.body)
		return worker.eventLoop.newSucceededFuture(result: response)
	}
}

class Server: IOProcessor {
	/// Configure the WebSocket which the HiveMind will run on
	struct Configuration {
		static let DefaultPortNumber = 8081

		/// Host on which the HiveMind will listen
		let hostname: String = "localhost"

		/// The port on which the HiveMind will listen
		let port: Int

		init(port: Int) {
			self.port = port
		}
	}

	/// Server configuration
	private let configuration: Configuration

	/// AI Actor
	private let actor: HiveMind

	/// Delegate
	private weak var delegate: IOProcessorDelegate?

	/// Primary HTTPServer
	private var server: HTTPServer!

	/// Server WebSocket connection
	private var socket: WebSocket!

	/// Worker that server events will be handled with.
	private var group: EventLoopGroup!

	init(configuration: Configuration, actor: HiveMind) throws {
		self.configuration = configuration
		self.actor = actor
	}

	deinit {
		exit()
	}

	// MARK: - IOProcessor

	func start(delegate: IOProcessorDelegate) throws {
		self.delegate = delegate
		self.group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
	}

	func run() throws {
		let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: { [weak self] _ in
			// Only upgrade a connection if there isn't already another open connection
			guard self?.socket == nil else { return nil }
			logger.debug("Connection to WebSocket opened.")
			return [:]
			}, onUpgrade: { [weak self] socket, _ in
				self?.socket = socket

				socket.onText { [weak self] _, text in
					guard let self = self else { return }
					let command = self.parse(text)
					self.delegate?.handle(command)
				}
		})

		self.server = try HTTPServer.start(
			hostname: configuration.hostname,
			port: configuration.port,
			responder: EchoResponder(),
			upgraders: [ws],
			on: group,
			onError: { error in
				logger.error("Error in WebSocket: \(error)")
			}).wait()

		logger.debug("HiveMind has initialized, listening on port \(configuration.port)")
		delegate?.handle(.ready)

		try server.onClose.wait()
	}

	/// Send a message across the socket.
	func send(_ output: Output) {
		socket.send(output.description)
	}

	// MARK: - Private

	/// Close the WebSocket
	func exit() {
		socket.close()
		group.shutdownGracefully { _ in }
	}

	/// Handle a response from the WebSocket connection and call appropriate delegate methods.
	private func parse(_ text: String) -> Command {
		let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard input.isEmpty == false else {
			logger.error("No input provided.")
			return .unknown
		}

		logger.debug("Parsing input: `\(input)`")

		let rawCommand = String(input.prefix(upTo: input.firstIndex(of: " ") ?? input.endIndex))
		var values: [String]?

		if let firstSpace = input.firstIndex(of: " ") {
			values = String(input.suffix(from: input.index(after: firstSpace))).split(separator: " ").map { String($0) }
		}

		return Command.from(command: rawCommand, withValues: values)
	}
}
