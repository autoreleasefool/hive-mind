package ca.josephroque.hivemind.main

import ca.josephroque.hivemind.common.ViewAction

/**
 * Copyright (C) 2019 Joseph Roque
 */
sealed class MainActivityViewAction : ViewAction {
    object TrainClicked : MainActivityViewAction()
    object PlayClicked : MainActivityViewAction()
}