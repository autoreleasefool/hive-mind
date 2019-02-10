package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The ant unit.
 */
data class Ant(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.ant
    override val type: Unit.Type = Unit.Type.Ant
}
