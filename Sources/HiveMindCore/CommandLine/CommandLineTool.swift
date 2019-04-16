//
//  CommandLineTool.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-02-12.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation
import HiveEngine

public class CommandLineTool {
	private var isRunning: Bool = false
	private let configuration: Configuration

	/// AI actor
	var actor: Actor!

	/// WebSocket wrapper
	private var server: Server!

	public init() {
		self.configuration = Configuration(from: CommandLine.arguments)
	}

	/// Open the Websocket
	public func run() {
		isRunning = true
		do {
			server = try Server(hostname: configuration.hostname, port: configuration.port, delegate: self)
		} catch {
			logger.error(error: error, "Failed to initialize the Server")
		}

		do {
			try server?.wait()
		} catch {
			logger.error(error: error, "Failed to wait for Server")
		}
	}

	// MARK: Commands

	/// Create a new HiveMind
	private func createActor(with options: HiveMind.Options) {
		actor = HiveMind(options: options)
	}

	/// Pass a `Movement` to the HiveMind
	private func apply(movement: Movement) {
		actor.apply(movement: movement)
	}

	/// Print the current best move from the HiveMind
	private func play() {
		actor.play { [weak self] movement in
			self?.server.send(.movement(movement))
		}
	}

	/// Exit the program
	private func exit() {
		isRunning = false
		server.exit()
	}
}

extension CommandLineTool: ServerDelegate {
	func serverDidReceiveResponse(server: Server, response: SocketResponse) {
		switch response {
		case .play:
			play()
		case .movement(let movement):
			apply(movement: movement)
		case .new(let options):
			createActor(with: options)
		case .exit:
			exit()
		case .unknown:
			server.send(.invalidCommand)
		}
	}

	func serverDidDisconnect(server: Server) {
		exit()
	}
}
