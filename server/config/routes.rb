Rails.application.routes.draw do
  resources :training_images

  post 'hivemind/new', to: 'hive_mind#new'
  post 'hivemind/play', to: 'hive_mind#play'
  post 'hivemind/moves', to: 'hive_mind#available_moves'

end
