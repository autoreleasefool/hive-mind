package ca.josephroque.hivemind.main

import androidx.lifecycle.ViewModel
import ca.josephroque.hivemind.common.Action
import ca.josephroque.hivemind.common.ViewAction
import com.shopify.livedataktx.LiveDataKtx
import com.shopify.livedataktx.MutableLiveDataKtx

/**
 * Copyright (C) 2019 Joseph Roque
 *
 * View Model for the main activity.
 */
class MainActivityViewModel : ViewModel() {

    private val _action = MutableLiveDataKtx<Action>()
    val action: LiveDataKtx<Action>
        get() = _action

    fun handleViewAction(action: ViewAction) {
        when (action) {
            is MainActivityViewAction.PlayClicked -> _action.postValue(MainActivityAction.OnPlayLaunched)
            is MainActivityViewAction.TrainClicked -> _action.postValue(MainActivityAction.OnTrainLaunched)
        }
    }

}