LatoSettings::Engine.routes.draw do
  root 'application#index'

  resources :settings
end
