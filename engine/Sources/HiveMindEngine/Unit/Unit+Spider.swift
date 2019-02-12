//
//  Unit+Spider.swift
//  HiveMind
//
//  Created by Joseph Roque on 2019-02-08.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

extension Unit {
	func movesAsSpider(in state: GameState) -> Set<Movement> {
		guard self.canMove(as: .spider, in: state) else { return [] }
		guard let startPosition = state.units[self], startPosition != .inHand else { return [] }

		let maxDistance = 3

		var moves = Set<Movement>()
		var visited = Set<Position>()
		var toVisit = [startPosition]
		var distance: [Position: Int] = [:]

		while toVisit.isNotEmpty {
			let currentPosition = toVisit.popLast()!
			visited.insert(currentPosition)

			currentPosition.adjacent()
				.filter {
					// Only consider valid playable positions that can be reached
					return state.playableSpaces.contains($0) && // Target position is adjacent to another piece
						currentPosition.freedomOfMovement(to: $0, in: state) && // Unit can freely move to the target position
						visited.contains($0) == false && // Unit cannot backtrack
						state.units(adjacentTo: currentPosition).intersection(state.units(adjacentTo: $0)).count > 0 // Target position shares at least 1 adjacent unit with the current position
				}.forEach {
					let distanceToRoot = distance[currentPosition]! + 1
					if distanceToRoot == maxDistance {
						// Spider moves exactly 3 spaces
						moves.insert(.move(unit: self, to: $0))
					} else if distanceToRoot < maxDistance {
						toVisit.append($0)
						distance[$0] = distanceToRoot
					}
			}
		}

		return moves
	}
}
