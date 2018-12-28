Rails.application.routes.draw do
  root 'top#index'
  get 'top', to: 'top#index'
  get 'top/index', to: 'top#index'
  get "top/index/:id" => "top#show"

  resources :sharings, only: %i[index], param: :category_name
  namespace :sharings do
    resources :searchers, only: %i[index]
  end
end
