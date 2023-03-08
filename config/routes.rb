require 'que/web'

Rails.application.routes.draw do
  mount Que::Web => '/secret/que'

  devise_for :users

  constraints host: ApplicationController.helpers.app_uri.host do
    resources :collections
  end

  resources :sources
  resources :items
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'items#index'
end
