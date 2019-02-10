package ca.josephroque.hivemind.game

import android.graphics.Bitmap
import ca.josephroque.hivemind.game.units.Unit
import java.util.*

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The state of a game of Hive.
 */
class GameState {

    companion object {
        const val PIECES_PER_SIDE = 14
        const val MAX_WIDTH = PIECES_PER_SIDE * 2 + 2
        const val MAX_HEIGHT = PIECES_PER_SIDE * 2 + 2
    }

    // Assume the client is white and it is always the client's turn
    val currentPlayer: Player = Player.White

    val cells: List<List<Unit>>

    constructor(bitmap: Bitmap) {
        val cells: MutableList<MutableList<Unit>> = ArrayList()
        this.cells = cells
    }
}