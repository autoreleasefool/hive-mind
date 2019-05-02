//
//  ZobristHash.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-30.
//

import Foundation
import HiveEngine


class ZobristHash {

	/// Max/min coordinate positive or negative that a random number has been generated for
	private var coordinateLimit: Int = 0
	/// Unique random numbers for units at each position and height
	private var unitPositionHashes: [Position: [Int: [HiveEngine.Unit.Class: Int64]]] = [:]
	/// Unique random numbers for each player
	private var playerHashes: [Player: Int64] = [:]

	/// Thread safe access to the hash
	private let bitLock = NSLock()

	/// The current key
	private(set) var key: Int64 = 0

	init() {
		playerHashes[Player.white] = randomNumber()
		playerHashes[Player.black] = randomNumber()
		extendCoordinateLimit()

		key ^= playerHashes[Player.white]!
	}

	/// Update the hash with a movement on the board
	///
	/// - Parameters:
	///   - unit: the Unit that was moved
	///   - from: the starting position of the unit
	///   - startHeight: the starting height of the unit
	///   - to: the ending position of the unit
	///   - endHeight: the ending height of the unit
	///   - lastPlayer: the player who made the move
	///   - newPlayer: the player to make the next move
	func move(unit: HiveEngine.Unit, from: Position, atHeight startHeight: Int, to: Position, atHeight endHeight: Int, lastPlayer: Player, newPlayer: Player) {
		guard let hashesForFromPosition = unitPositionHashes[from], let hashesForToPosition = unitPositionHashes[to] else {
			extendCoordinateLimit()
			move(unit: unit, from: from, atHeight: startHeight, to: to, atHeight: endHeight, lastPlayer: lastPlayer, newPlayer: newPlayer)
			return
		}

		key ^= playerHashes[lastPlayer]!
		key ^= playerHashes[newPlayer]!
		key ^= hashesForFromPosition[startHeight]![unit.class]!
		key ^= hashesForToPosition[startHeight]![unit.class]!

	}

	/// Generate hashes for a Position at all heights and for all units.
	private func generateHashes(for position: Position) {
		if unitPositionHashes[position] == nil {
			unitPositionHashes[position] = [:]
		}

		for height in 0...7 {
			if unitPositionHashes[position]![height] == nil {
				unitPositionHashes[position]![height] = [:]
			}

			for unitClass in HiveEngine.Unit.Class.allCases {
				unitPositionHashes[position]![height]![unitClass] = randomNumber()
			}
		}
	}

	/// Generate random numbers for additional coordinate values that do not already have one.
	private func extendCoordinateLimit() {
		defer { bitLock.unlock() }
		bitLock.lock()

		let originalLimit = coordinateLimit
		if coordinateLimit == 0 {
			coordinateLimit += 4
		}
		coordinateLimit *= 2

		let positiveRange = originalLimit..<coordinateLimit
		for x in positiveRange {
			for y in positiveRange {
				for z in positiveRange {
					generateHashes(for: Position(x: x, y: y, z: z))
				}
			}
		}

		let negativeRange = (-coordinateLimit + 1)..<(-originalLimit)
		for x in negativeRange {
			for y in negativeRange {
				for z in negativeRange {
					generateHashes(for: Position(x: x, y: y, z: z))
				}
			}
		}
	}

	/// Produce random numbers consistently
	private func randomNumber() -> Int64 {
		return Int64.random(in: Int64.min...Int64.max)
	}
}
