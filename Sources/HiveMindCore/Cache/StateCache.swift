//
//  StateCache.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-06.
//

import Foundation
import HiveEngine

class StateCache {

	/// Version of the cache, to be updated when the evaluation algorithm changes
	static let version: Int = 2

	/// Location of test directory
	private var baseURL: URL {
		return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
	}

	/// Location of cache
	private var cacheURL: URL {
		return baseURL.appendingPathComponent(".HiveMindCache", isDirectory: true)
	}

	/// Location of cache file
	private var cacheFile: URL {
		return cacheURL.appendingPathComponent("\(StateCache.version).txt")
	}

	/// Map of cached states to evaluated value
	private var cache: [String: Int] = [:]

	/// Disables the cache
	private let disabled: Bool

	// Statistic tracking
	private var hits = 0
	private var misses = 0

	init(disabled: Bool = false) throws {
		self.disabled = disabled
		try FileManager.default.createDirectory(at: cacheURL, withIntermediateDirectories: true)

		let file = cacheFile
		do {
			let rawCache = try String(contentsOf: file, encoding: .utf8)
			for entry in rawCache.split(separator: "\n") {
				guard entry.isEmpty == false else { continue }
				let keyValue = entry.split(separator: "=")
				cache[String(keyValue[0])] = Int(String(keyValue[1]))
			}
		} catch {
			print(error)
		}
	}

	/// Given a `GameState`, determines if the value has been cached and returns the cached value if so.
	subscript(index: GameState) -> Int? {
		get {
			guard disabled == false else { return nil }
			let cacheable = index.cacheable
			if let value = cache[cacheable.rawValue] {
				hits += 1
				return value
			}

			misses += 1
			return nil
		}
		set(newValue) {
			let cacheable = index.cacheable
			cache[cacheable.rawValue] = newValue
		}
	}

	func flush() {
		let totalQueries = hits + misses
		let successfulPercent = Double(hits) / Double(totalQueries) * 100
		print("Total cache hits: \(hits)\\\(totalQueries) (\(successfulPercent)%)")

		var rawCache = ""
		for entry in cache {
			rawCache.append(entry.key)
			rawCache.append("=")
			rawCache.append(String(entry.value))
			rawCache.append("\n")
		}

		do {
			try rawCache.write(to: cacheFile, atomically: false, encoding: .utf8)
		} catch {
			print(error)
		}
	}
}
