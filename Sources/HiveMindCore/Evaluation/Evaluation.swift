//
//  Evaluation.swift
//  HiveEngine
//
//  Created by Joseph Roque on 2019-03-28.
//

import HiveEngine

/// Evaluate a GameState and return a higher value if it is a better position for the current player,
/// and a lower value if it is a better position for the opponent.
typealias Evaluator = (GameState, GameStateSupport) -> Int
