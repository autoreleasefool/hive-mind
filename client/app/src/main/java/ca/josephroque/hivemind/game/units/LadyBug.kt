package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The lady bug unit.
 */
data class LadyBug(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.lady_bug
    override val type: Unit.Type = Unit.Type.LadyBug
}
