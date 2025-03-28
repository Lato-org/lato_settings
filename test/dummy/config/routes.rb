Rails.application.routes.draw do
  mount Lato::Engine => "/lato"
  mount LatoSettings::Engine => "/lato_settings"

  root 'application#index'

  get 'documentation', to: 'application#documentation', as: :documentation
end
