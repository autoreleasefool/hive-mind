//
//  Movement+Extensions.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-03.
//

import Foundation
import HiveEngine

extension Movement {
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8)!
	}
}

extension Array where Array.Element == Movement {
	func json() -> String {
		let encoder = JSONEncoder()
		guard let data = try? encoder.encode(self) else { return "" }
		return String(data: data, encoding: .utf8)!
	}
}
