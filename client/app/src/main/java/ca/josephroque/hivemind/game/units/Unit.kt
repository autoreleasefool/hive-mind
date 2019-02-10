package ca.josephroque.hivemind.game.units

import android.content.res.Resources

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * A `unit` is one piece of the game, one bug in the hive.
 */
interface Unit {
    val name: Int
    val type: Unit.Type
    val isFriendly: Boolean

    fun getNameString(resources: Resources): String {
        return resources.getString(name)
    }

    enum class Type {
        Ant,
        Hopper,
        Spider,
        Beetle,
        Mosquito,
        LadyBug,
        PillBug,
        Queen
    }
}
