package ca.josephroque.hivemind.game

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * Describes a movement from one position to another.
 */
sealed class Movement {
    data class Move(val unit: Unit, val target: Position) : Movement()
    data class Yoink(val unit: Unit, val target: Position) : Movement()
    data class Place(val unit: Unit, val target: Position) : Movement()
}
