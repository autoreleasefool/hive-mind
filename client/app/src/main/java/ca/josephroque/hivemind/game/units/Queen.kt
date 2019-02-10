package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The queen unit.
 */
data class Queen(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.queen
    override val type: Unit.Type = Unit.Type.Queen
}
