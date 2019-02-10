package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The pill bug unit.
 */
data class PillBug(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.pill_bug
    override val type: Unit.Type = Unit.Type.PillBug
}
