Rails.application.routes.draw do
  root 'top#index'

  resources :sharings, only: [:index]
end
