//
//  Player+Extensions.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-03-18.
//

import HiveEngine

extension Player: Comparable {
	public static func < (lhs: Player, rhs: Player) -> Bool {
		switch (lhs, rhs) {
		case (.white, .white): return false
		case (.white, .black): return true
		case (.black, .white): return false
		case (.black, .black): return false
		}
	}
}
