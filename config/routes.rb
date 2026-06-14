Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  namespace :admin do
    resources :users, only: [:index, :edit, :update]
    get "analytics", to: "analytics#index"
  end

  namespace :merchant do
    root "dashboard#index"
    resources :products, only: [:index, :new, :create, :edit, :update]
    resources :services, only: [:index, :new, :create, :edit, :update]
    resources :shops, only: [:edit, :update]
    get "inventory", to: "inventory#index"
    resources :orders, only: [:index, :update]
    get "analytics", to: "analytics#index"
  end

  namespace :customer do
    resources :orders, only: [:index, :show]
    get "analytics", to: "analytics#index"
  end

  resources :products
  resources :suppliers
  resources :locations

  get "catalog", to: "catalog#index"
  get "catalog/:id", to: "catalog#show", as: :catalog_product
  get "merchants/:id", to: "merchants#show", as: :merchant_storefront
  resources :services, only: [:index, :show]
  resource :cart, only: [:show, :create, :update, :destroy]
  resource :checkout, only: [:show, :create]
  resources :payments, only: [:create]
  resources :reviews, only: [:create]
  resources :notifications, only: [:index, :update]
  namespace :webhooks do
    post "payments/manual", to: "payments#create"
  end

  get "dashboard", to: "dashboard#index"
  root "dashboard#index"

  get "inventory", to: "inventory#index"
  post "inventory/adjust", to: "inventory#adjust_stock"
end
