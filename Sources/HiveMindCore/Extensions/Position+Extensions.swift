//
//  Position+Extensions.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-06.
//

import HiveEngine

extension Position: Comparable {
	public static func < (lhs: Position, rhs: Position) -> Bool {
		if lhs.x != rhs.x {
			return lhs.x < rhs.x
		} else if lhs.y < rhs.y {
			return lhs.y < rhs.y
		} else {
			return lhs.z < rhs.z
		}
	}
}
