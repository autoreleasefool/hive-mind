//
//  Movement.swift
//  HiveMindEngine
//
//  Created by Joseph Roque on 2019-02-07.
//  Copyright © 2019 Joseph Roque. All rights reserved.
//

import Foundation

public enum Movement: Hashable, Equatable {
	case move(unit: Unit, to: Position)
	case yoink(pillBug: Unit, unit: Unit, to: Position)
	case place(unit: Unit, at: Position)
}
