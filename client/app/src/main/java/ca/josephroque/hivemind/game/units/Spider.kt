package ca.josephroque.hivemind.game.units

import ca.josephroque.hivemind.R

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * The spider unit.
 */
data class Spider(override val isFriendly: Boolean) : Unit {
    override val name: Int = R.string.spider
    override val type: Unit.Type = Unit.Type.Spider
}
