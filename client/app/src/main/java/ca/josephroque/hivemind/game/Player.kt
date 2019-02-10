package ca.josephroque.hivemind.game

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The available players.
 */
enum class Player {
    White, Black;

    val next: Player
        get() {
            return when (this) {
                White -> Black
                Black -> White
            }
        }
}