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
	static let version: Int = 3

	/// Location of test directory
	private var baseURL: URL? {
		return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
	}

	/// Location of cache
	private var cacheDirectory: URL? {
		return baseURL?.appendingPathComponent(".HiveMindCache", isDirectory: true)
	}

	/// Location of cache file
	private var cacheFile: URL? {
		return cacheDirectory?.appendingPathComponent("v\(StateCache.version)_cache.txt")
	}

	/// Location of bit cache file
	private var bitCacheFile: URL? {
		return cacheDirectory?.appendingPathComponent("v\(StateCache.version)_bits.txt")
	}

	/// Map of cached states to evaluated value
	private var cache: [Int: Int] = [:]

	/// Disables the cache
	private let disabled: Bool

	/// Number of times that the cache contains a value for a state
	private var hits = 0
	/// Number of times that the cache does not contain a value for a state
	private var misses = 0

	init(disabled: Bool = false) throws {
		self.disabled = disabled
		try FileManager.default.createDirectory(at: cacheDirectory!, withIntermediateDirectories: true)

		do {
			if let cacheFile = self.cacheFile, let bitCacheFile = self.bitCacheFile {
				try loadCache(file: cacheFile)
				try loadBitCache(file: bitCacheFile)
			}
		} catch {
			logger.error(error: error)
		}

		HiveEngine.Unit.Class.allCases.forEach {
			if unitBits[$0] == nil {
				unitBits[$0] = Int.random(in: Int.min...Int.max)
			}
		}
	}

	private func loadCache(file: URL) throws {
		let rawCache = try String(contentsOf: file, encoding: .utf8)
		rawCache.split(separator: "\n").forEach {
			guard $0.isEmpty == false else { return }
			let keyValue = $0.split(separator: "=")
			cache[Int(keyValue[0])!] = Int(keyValue[1])
		}
	}

	private func loadBitCache(file: URL) throws {
		let rawBitCache = try String(contentsOf: file, encoding: .utf8)
		let bitCacheEntries = rawBitCache.split(separator: "\n")
		bitLimit = Int(bitCacheEntries[0])!

		bitCacheEntries.dropFirst().forEach {
			guard $0.isEmpty == false else { return }
			let keyValue = $0.split(separator: "=")
			switch keyValue[0] {
			case "x": xBits[Int(keyValue[1])!] = Int(keyValue[2])
			case "y": yBits[Int(keyValue[1])!] = Int(keyValue[2])
			case "z": zBits[Int(keyValue[1])!] = Int(keyValue[2])
			case "u": unitBits[HiveEngine.Unit.Class(rawValue: String(keyValue[1]))!] = Int(keyValue[2])
			default: break
			}
		}
	}

	/// Given a `GameState`, determines if the value has been cached and returns the cached value if so.
	subscript(index: GameState) -> Int? {
		get {
			guard disabled == false else { return nil }
			let cacheIndex = hash(index)
			if let value = cache[cacheIndex] {
				hits += 1
				return value
			}

			misses += 1
			return nil
		}
		set(newValue) {
			let cacheIndex = hash(index)
			cache[cacheIndex] = newValue
		}
	}

	func flush() {
		guard disabled == false else { return }
		let totalQueries = hits + misses
		let successfulPercent = Double(hits) / Double(totalQueries) * 100
		logger.debug("Total cache hits: \(hits)\\\(totalQueries) (\(successfulPercent)%)")

		var rawCache = ""
		cache.forEach { rawCache.append("\($0.key)=\($0.value)\n") }

		var rawBitCache = "\(bitLimit)\n"
		xBits.forEach { rawBitCache.append("x=\($0.key)=\($0.value)\n") }
		rawBitCache.append("{y}\n")
		yBits.forEach { rawBitCache.append("y=\($0.key)=\($0.value)\n") }
		rawBitCache.append("{z}\n")
		zBits.forEach { rawBitCache.append("z=\($0.key)=\($0.value)\n") }
		rawBitCache.append("{units}\n")
		unitBits.forEach { rawBitCache.append("u=\($0.key.rawValue)=\($0.value)\n") }

		do {
			if let cacheFile = self.cacheFile, let bitCacheFile = self.bitCacheFile {
				try rawCache.write(to: cacheFile, atomically: false, encoding: .utf8)
				try rawBitCache.write(to: bitCacheFile, atomically: false, encoding: .utf8)
			}
		} catch {
			logger.error(error: error)
		}
	}

	// MARK: - Hashing GameState

	private var bitLimit = 6
	private var xBits: [Int: Int] = [:]
	private var yBits: [Int: Int] = [:]
	private var zBits: [Int: Int] = [:]
	private var unitBits: [HiveEngine.Unit.Class: Int] = [:]

	private func hash(_ state: GameState) -> Int {
		var cv = 0
		state.stacks.forEach {
			cv ^= hash($0.key)
			$0.value.forEach {
				cv ^= unitBits[$0.class]!
			}
		}
		return cv
	}

	private func hash(_ position: Position) -> Int {
		var cv = 0
		var hashed = false
		repeat {
			if let x = xBits[position.x], let y = yBits[position.y], let z = zBits[position.z] {
				cv ^= x
				cv ^= y
				cv ^= z
				hashed = true
			} else {
				bitLimit *= 2
				for i in -bitLimit..<bitLimit {
					if xBits[i] == nil { xBits[i] = Int.random(in: Int.min...Int.max) }
					if yBits[i] == nil { yBits[i] = Int.random(in: Int.min...Int.max) }
					if zBits[i] == nil { zBits[i] = Int.random(in: Int.min...Int.max) }
				}
			}
		} while (!hashed)

		return cv
	}
}
