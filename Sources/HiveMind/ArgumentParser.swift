//
//  File.swift
//  HiveMind
//
//  Created by Joseph Roque on 2019-04-21.
//

import Foundation

enum ArgumentError: LocalizedError {
	case invalidDefaultType(Any.Type?, Any.Type)
	case missingRequiredParam(String)
	case unrecognizedArgument(String)
	case duplicateArgument(String)

	var errorDescription: String? {
		switch self {
		case .invalidDefaultType(let type, let value):
			let typeDescription: String
			if let type = type {
				typeDescription = String(describing: type)
			} else {
				typeDescription = "nothing"
			}
			return "The default value type provided was invalid, expected \(typeDescription), got \(value)"
		case .missingRequiredParam(let param): return "The param \(param) was required but was not provided"
		case .unrecognizedArgument(let arg): return "The argument \(arg) was not recognized"
		case .duplicateArgument(let arg): return "The argument \(arg) was provided more than once"
		}
	}
}

/// Available types of arguments
enum ArgumentType {
	case int
	case double
	case string
	case bool
	case flag
}

/// An argument for the program
struct Argument {
	/// The identifier for the argument
	let identifier: String
	/// The type of argument
	let argumentType: ArgumentType
	/// Indicates if the argument is required to be passed in
	let required: Bool
	/// The default value of the argument, if any. Must be valid for the given `ArgumentType`
	let defaultValue: Any?

	init(identifier: String, argumentType: ArgumentType, required: Bool, defaultValue: Any?) throws {
		self.identifier = identifier
		self.argumentType = argumentType
		self.required = required
		self.defaultValue = defaultValue

		guard let value = defaultValue else { return }

		switch argumentType {
		case .int:
			if defaultValue is Int == false {
				throw ArgumentError.invalidDefaultType(Int.self, type(of: value))
			}
		case .double:
			if defaultValue is Double == false {
				throw ArgumentError.invalidDefaultType(Double.self, type(of: value))
			}
		case .string:
			if value is String == false {
				throw ArgumentError.invalidDefaultType(String.self, type(of: value))
			}
		case .bool:
			if value is Bool == false {
				throw ArgumentError.invalidDefaultType(Bool.self, type(of: value))
			}
		case .flag:
			throw ArgumentError.invalidDefaultType(nil, type(of: value))
		}
	}
}

struct ArgumentParser {

	/// The arguments to be parsed
	private var arguments: [String: Argument] = [:]

	/// Add an argument to the parser.
	///
	/// - Parameters:
	///   - arg: identifier for the argument
	///   - type: the type of value which must be passed with this argument
	///   - required: true if the argument is required, false if it is not
	///   - defaultValue: default value for the argument, or nil if a value must be passed
	mutating func add(arg: String, ofType type: ArgumentType, required: Bool = false, defaultValue: Any? = nil) throws {
		let argument = try Argument(identifier: arg, argumentType: type, required: required, defaultValue: defaultValue)

		if arguments[argument.identifier] != nil {
			throw ArgumentError.duplicateArgument(argument.identifier)
		}

		arguments[argument.identifier] = argument
	}

	/// Parse the given array of strings as arguments.
	///
	/// - Parameters:
	///   - args the list of arguments to parse
	func parse(_ args: [String] = CommandLine.arguments) throws -> [Arguments] {
		var usedArgs: Set<String> = Set()

		for (index, argumentIdentifier) in args.enumerated() {
			guard let argument = arguments[argumentIdentifier] else {
				throw ArgumentError.unrecognizedArgument(argumentIdentifier)
			}

			guard usedArgs.contains(argument.identifier) == false else {
				throw ArgumentError.duplicateArgument(argument.identifier)
			}

			switch argument.argumentType {
			case .flag:
			}

			usedArgs.insert(argument.identifier)
		}
	}
}

struct Arguments {
	fileprivate(set) var arguments: [String: Any]
}
