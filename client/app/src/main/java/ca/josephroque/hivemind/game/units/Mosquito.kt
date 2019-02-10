package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The mosquito unit.
 */
data class Mosquito(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.mosquito
    override val type: Unit.Type = Unit.Type.Mosquito
}
