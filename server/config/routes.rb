Rails.application.routes.draw do

  post 'hivemind/new', to: 'hive_mind#new'
  post 'hivemind/play', to: 'hive_mind#play'

end
