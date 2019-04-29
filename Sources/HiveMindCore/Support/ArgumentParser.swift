//
//  File.swift
//  HiveMind
//
//  Created by Joseph Roque on 2019-04-21.
//

import Foundation

/// Errors during argument parsing
enum ArgumentError: LocalizedError {
	case invalidDefaultType(Any.Type?, Any.Type)
	case missingRequiredParam(String)
	case unrecognizedArgument(String)
	case duplicateArgument(String)
	case invalidValue(Any.Type, String)
	case missingValue(String)

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
		case .invalidValue(let type, let value): return "Could not parse \(type) from \(value)"
		case .missingRequiredParam(let param): return "The param \(param) was required but was not provided"
		case .unrecognizedArgument(let arg): return "The argument \(arg) was not recognized"
		case .duplicateArgument(let arg): return "The argument \(arg) was provided more than once"
		case .missingValue(let arg): return "No value was provided for \(arg)"
		}
	}
}

/// Available types of arguments
enum ArgumentType: String {
	case int
	case double
	case string
	case bool
	case flag
}

/// Values for arguments
enum ArgumentValue: CustomStringConvertible {
	case int(Int)
	case double(Double)
	case string(String)
	case bool(Bool)
	case flag

	var description: String {
		switch self {
		case .int(let value): return "\(value)"
		case .double(let value): return "\(value)"
		case .string(let value): return "\(value)"
		case .bool(let value): return "\(value)"
		case .flag: return "none"
		}
	}
}

/// An argument for the program
struct Argument {
	/// The identifier for the argument
	let identifier: String
	/// Description of the effects of the argument
	let description: String?
	/// The type of argument
	let argumentType: ArgumentType
	/// Indicates if the argument is required to be passed in
	let required: Bool
	/// The default value of the argument, if any. Must be valid for the given `ArgumentType`
	let defaultValue: ArgumentValue?

	init(identifier: String, description: String?, argumentType: ArgumentType, required: Bool, defaultValue: ArgumentValue?) throws {
		self.identifier = Argument.identifier(from: identifier)
		self.description = description
		self.argumentType = argumentType
		self.required = required
		self.defaultValue = defaultValue

		guard let value = defaultValue else { return }

		switch argumentType {
		case .int:
			guard case .int = value else { throw ArgumentError.invalidDefaultType(Int.self, type(of: value)) }
		case .double:
			guard case .double = value else { throw ArgumentError.invalidDefaultType(Double.self, type(of: value)) }
		case .string:
			guard case .string = value else { throw ArgumentError.invalidDefaultType(String.self, type(of: value)) }
		case .bool:
			guard case .bool = value else { throw ArgumentError.invalidDefaultType(Bool.self, type(of: value)) }
		case .flag:
			throw ArgumentError.invalidDefaultType(nil, type(of: value))
		}
	}

	static func identifier(from raw: String) -> String {
		let base = raw.starts(with: "--") ? String(raw.suffix(from: raw.index(raw.startIndex, offsetBy: 2))) : raw
		guard base.isEmpty == false && base.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil else { fatalError("\(base) is not a valid alphanumeric identifier") }
		return "--\(base)"
	}
}

extension Argument: Comparable {
	public static func == (lhs: Argument, rhs: Argument) -> Bool {
		return lhs.identifier == rhs.identifier
	}

	public static func < (lhs: Argument, rhs: Argument) -> Bool {
		return lhs.identifier < rhs.identifier
	}
}

struct ArgumentParser {

	let name: String
	let description: String

	private var arguments: [String: Argument] = [:]

	private var flags: [Argument] {
		return arguments.compactMap {
			return $0.value.argumentType == .flag ? $0.value : nil
		}
	}

	private var valueArguments: [Argument] {
		return arguments.compactMap {
			return $0.value.argumentType != .flag ? $0.value : nil
		}
	}

	init(name: String, description: String) {
		self.name = name
		self.description = description

		try! add(arg: "help", ofType: .flag, description: "Output the help message")
	}

	/// Add an argument to the parser.
	///
	/// - Parameters:
	///   - arg: identifier for the argument
	///   - type: the type of value which must be passed with this argument
	///   - description: describe the effect of the argument
	///   - required: true if the argument is required, false if it is not
	///   - defaultValue: default value for the argument, or nil if a value must be passed
	mutating func add(arg: String, ofType type: ArgumentType, description: String? = nil, required: Bool = false, defaultValue: ArgumentValue? = nil) throws {
		let argument = try Argument(identifier: arg, description: description, argumentType: type, required: required, defaultValue: defaultValue)

		if arguments[argument.identifier] != nil {
			throw ArgumentError.duplicateArgument(argument.identifier)
		}

		arguments[argument.identifier] = argument
	}

	// swiftlint:disable cyclomatic_complexity
	// Ignore complexity for parsing arguments

	/// Parse the given array of strings as arguments.
	///
	/// - Parameters:
	///   - args the list of arguments to parse
	func parse(_ args: [String]) throws -> Arguments {
		var usedArgs: Set<String> = Set()
		var parsedArgs = Arguments()

		var index = 0
		while index < args.count {
			let identifier = args[index]
			guard let argument = arguments[identifier] else {
				throw ArgumentError.unrecognizedArgument(identifier)
			}

			guard usedArgs.contains(argument.identifier) == false else {
				throw ArgumentError.duplicateArgument(argument.identifier)
			}

			guard argument.argumentType == .flag || index + 1 < args.count else {
				throw ArgumentError.missingValue(argument.identifier)
			}

			switch argument.argumentType {
			case .flag:
				parsedArgs.flags.insert(argument.identifier)
			case .bool:
				guard let value = Bool(args[index + 1]) else { throw ArgumentError.invalidValue(Bool.self, args[index + 1]) }
				parsedArgs.arguments[argument.identifier] = .bool(value)
				index += 1
			case .double:
				guard let value = Double(args[index + 1]) else { throw ArgumentError.invalidValue(Double.self, args[index + 1]) }
				parsedArgs.arguments[argument.identifier] = .double(value)
				index += 1
			case .int:
				guard let value = Int(args[index + 1]) else { throw ArgumentError.invalidValue(Int.self, args[index + 1]) }
				parsedArgs.arguments[argument.identifier] = .int(value)
				index += 1
			case .string:
				parsedArgs.arguments[argument.identifier] = .string(args[index + 1])
				index += 1
			}

			usedArgs.insert(argument.identifier)
			index += 1
		}

		for arg in arguments.values {
			if parsedArgs.argumentValue(of: arg.identifier) == nil {
				if arg.required {
					throw ArgumentError.missingRequiredParam(arg.identifier)
				} else if let defaultValue = arg.defaultValue {
					parsedArgs.arguments[arg.identifier] = defaultValue
				}
			}
		}

		if parsedArgs.isFlagPresent(flag: "help") {
			logger.write(help())
		}

		return parsedArgs
	}

	//swiftlint:enable cyclomatic_complexity

	/// Prints the argument details
	func help() -> String {
		var output = "\(name) - \(description)"

		for flag in flags.sorted() {
			output += "\n\t"

			let required = flag.required ? " [required]" : ""
			if let desc = flag.description {
				output += "\(flag)\(required): \(desc)"
			} else {
				output += "\(flag)\(required)"
			}
		}

		for arg in valueArguments.sorted() {
			output += "\n\t"

			let required = arg.required ? " [required]" : ""

			let defaults: String
			if let defaultValue = arg.defaultValue {
				defaults = ", default: \(defaultValue.description)"
			} else {
				defaults = ""
			}

			if let desc = arg.description {
				output += "\(arg)\(required) <\(arg.argumentType.rawValue)>: \(desc)\(defaults)"
			} else {
				output += "\(arg)\(required) <\(arg.argumentType.rawValue)>\(defaults)"
			}
		}

		return output
	}
}

/// Parsed arguments
struct Arguments {
	fileprivate var arguments: [String: ArgumentValue] = [:]
	fileprivate var flags: Set<String> = []

	/// Indicates if a flag was provided as an argument
	func isFlagPresent(flag: String) -> Bool {
		let identifier = Argument.identifier(from: flag)
		return flags.contains(identifier)
	}

	/// Gets the value of an argument, if the argument was provided
	func argumentValue(of arg: String) -> ArgumentValue? {
		let identifier = Argument.identifier(from: arg)
		return arguments[identifier]
	}

	/// Gets the value of an argument, as a given type. Returns nil if the argument was not provided,
	/// or it is not of the type given.
	func argumentValue<T>(of identifier: String, as type: T.Type) -> T? {
		guard let argValue = argumentValue(of: identifier) else { return nil }
		switch argValue {
		case .int(let value): return value as? T
		case .double(let value): return value as? T
		case .bool(let value): return value as? T
		case .string(let value): return value as? T
		case .flag: return nil
		}

	}
}
