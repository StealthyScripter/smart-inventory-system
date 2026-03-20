Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  namespace :admin do
    resources :users, only: [:index, :edit, :update]
  end

  resources :products
  resources :suppliers
  resources :locations

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"

  get "inventory", to: "inventory#index"
  post "inventory/adjust", to: "inventory#adjust_stock"
end
