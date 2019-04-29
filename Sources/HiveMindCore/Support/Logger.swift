//
//  Logger.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-17.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

class Logger {
	/// Logger levels
	enum LogLevel {
		/// All messages are printed
		case debug
		/// Debug messages are not printed. Only error messages and release messages
		case error
		/// Only messages meant for the release version are printed
		case release
	}

	/// Current log level
	var level: LogLevel

	init(level: LogLevel = .debug) {
		self.level = level
	}

	private func truncate(filename: String) -> String {
		return String(filename.split(separator: "/").last ?? "")
	}

	/// Print a message, only if debug logging is enabled
	func debug(_ msg: String..., separator: String = " ", file: StaticString = #file) {
		guard resolve(.debug) else { return }
		let filename = truncate(filename: "\(file)")
		print("[\(filename)]", msg.joined(separator: separator))
	}

	/// Print an error and a message, only if error logging is enabled
	func error(error: Error? = nil, _ msg: String..., separator: String = " ", file: StaticString = #file) {
		guard resolve(.error) else { return }
		let filename = truncate(filename: "\(file)")
		if let error = error {
			print("[\(filename)]", msg.joined(separator: separator), error)
		} else {
			print("[\(filename)]", msg.joined(separator: separator))
		}
	}

	/// Print a message, always
	func write(_ msg: String..., separator: String = " ") {
		guard resolve(.release) else { return }
		print(msg.joined(separator: separator))
	}

	private func resolve(_ messageLevel: LogLevel) -> Bool {
		switch (level, messageLevel) {
		case (.release, .release): return true
		case (.debug, _): return true
		case (_, .debug): return false
		case (.error, _): return true
		case (_, .error): return false
		}
	}
}

#if DEBUG
let logger = Logger()
#else
let logger = Logger(level: .release)
#endif
