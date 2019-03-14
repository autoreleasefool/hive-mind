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

	private var cache: [String: Int] = [:]

	init() throws {
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

	var hits = 0
	var misses = 0

	func evaluate(state: GameState, with support: GameStateSupport) -> Int {
		let cacheable = state.cacheable
		if let value = cache[cacheable.rawValue] {
			hits += 1
			return value
		} else {
			misses += 1
//			print(cacheable.rawValue)
			let value = state.evaluate(with: support)
			cache[cacheable.rawValue] = value
			return value
		}
	}

	func flush() {
		print("Hits: \(hits)")
		print("Misses: \(misses)")
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
