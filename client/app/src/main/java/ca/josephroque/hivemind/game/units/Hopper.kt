package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The hopper unit.
 */
data class Hopper(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.hopper
    override val type: Unit.Type = Unit.Type.Hopper
}
