package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The beetle unit.
 */
data class Beetle(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.beetle
    override val type: Unit.Type = Unit.Type.Beetle
}
