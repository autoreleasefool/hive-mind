//
//  Player.swift
//  HiveMind
//
//  Created by Joseph Roque on 2019-02-08.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

/// Players of the game
public enum Player {
	/// The first player, white
	case white
	/// The second player, black
	case black

	/// Returns the next player
	public var next: Player {
		switch self {
		case .black: return .white
		case .white: return .black
		}
	}
}
