package ca.josephroque.hivemind.main

import ca.josephroque.hivemind.common.Action

/**
 * Copyright (C) 2019 Joseph Roque
 */
sealed class MainActivityAction : Action {
    object OnTrainLaunched : MainActivityAction()
    object OnPlayLaunched : MainActivityAction()
}