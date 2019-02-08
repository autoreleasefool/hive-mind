package ca.josephroque.hivemind.main

import android.os.Bundle
import android.util.Log
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import ca.josephroque.hivemind.R
import ca.josephroque.hivemind.common.Action
import kotlinx.android.synthetic.main.activity_main.*

/**
 * Main entry point of the application.
 */
class MainActivity : FragmentActivity() {

    companion object {
        private const val TAG = "MainActivity"
    }

    private lateinit var viewModel: MainActivityViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        viewModel = ViewModelProviders.of(this).get(MainActivityViewModel::class.java)
        viewModel.action.observe(this, Observer<Action> { handleAction(it) })

        train.setOnClickListener { viewModel.handleViewAction(MainActivityViewAction.TrainClicked) }
        play.setOnClickListener { viewModel.handleViewAction(MainActivityViewAction.PlayClicked) }
    }

    private fun handleAction(action: Action) {
        when (action) {
            is MainActivityAction.OnPlayLaunched -> Log.d(TAG, "Launched Play")
            is MainActivityAction.OnTrainLaunched -> Log.d(TAG, "Launched Train")
        }
    }
}
