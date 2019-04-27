//
//  Output.swift
//  HiveMindCore
//
//  Created by Joseph Roque on 2019-04-22.
//

import HiveEngine

enum Output: CustomStringConvertible {
	case success
	case failure
	case movement(Movement)

	var description: String {
		switch self {
		case .success: return "SUCCESS"
		case .failure: return "FAILED"
		case .movement(let movement): return movement.json()
		}
	}
}
