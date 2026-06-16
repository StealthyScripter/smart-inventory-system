Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "customers/sign_in", to: "sessions#new", defaults: { login_context: "customer" }, as: :customers_sign_in
  post "customers/sign_in", to: "sessions#create", defaults: { login_context: "customer" }
  get "customers/sign_up", to: "customer_registrations#new", as: :customers_sign_up
  post "customers/sign_up", to: "customer_registrations#create"
  get "merchants/sign_in", to: "sessions#new", defaults: { login_context: "merchant" }, as: :merchants_sign_in
  post "merchants/sign_in", to: "sessions#create", defaults: { login_context: "merchant" }
  get "merchants/sign_up", to: "merchant_registrations#new", as: :merchants_sign_up
  post "merchants/sign_up", to: "merchant_registrations#create"

  namespace :admin do
    resources :users, only: [:index, :edit, :update]
    get "analytics", to: "analytics#index"
    get "moderation", to: "moderation#index"
    resources :reports, only: [:index, :update]
    resources :moderation_actions, only: [:create]
  end

  namespace :merchant do
    root "dashboard#index"
    get "catalog", to: "catalog#index"
    resource :profile, only: [:show]
    resources :products, only: [:index, :new, :create, :edit, :update]
    post "products/bulk_update", to: "product_operations#bulk_update", as: :product_bulk_update
    post "products/:product_id/duplicate", to: "product_operations#duplicate", as: :product_duplicate
    get "products_export", to: "product_operations#export", as: :products_export
    post "products_import", to: "product_operations#import", as: :products_import
    resources :services, only: [:index, :new, :create, :edit, :update]
    resources :service_bookings, only: [:index, :update] do
      member do
        get :estimate
      end
    end
    resources :conversations, only: [:index]
    resources :shops, only: [:edit, :update]
    resource :account_settings, only: [:edit, :update]
    resources :members, only: [:index, :create, :update, :destroy] do
      member do
        patch :enable
      end
    end
    get "inventory", to: "inventory#index"
    patch "inventory/:id", to: "inventory#update", as: :inventory_item
    resources :orders, only: [:index, :update]
    get "analytics", to: "analytics#index"
  end

  namespace :customer do
    resource :profile, only: [:show]
    resources :orders, only: [:index, :show]
    resources :service_bookings, only: [:index, :update]
    resources :conversations, only: [:index]
    get "analytics", to: "analytics#index"
  end

  resources :products do
    member do
      get :barcode
      get :qr_code
    end
  end
  resources :suppliers
  resources :locations

  get "catalog", to: "catalog#index"
  get "catalog/:id", to: "catalog#show", as: :catalog_product
  get "search", to: "search#index"
  get "merchants/:id", to: "merchants#show", as: :merchant_storefront
  resources :services, only: [:index, :show]
  resources :service_bookings, only: [:create]
  resource :cart, only: [:show, :create, :update, :destroy]
  resource :checkout, only: [:show, :create]
  resources :payments, only: [:create]
  resources :reviews, only: [:create]
  resources :reports, only: [:create]
  resources :notifications, only: [:index, :update]
  resources :conversations, only: [:show, :create]
  post "conversations/:id", to: "conversations#create"
  namespace :webhooks do
    post "payments/manual", to: "payments#create"
    post "payments/:provider", to: "payments#create", as: :provider_payment
  end

  get "dashboard", to: "dashboard#index"
  root "catalog#index"

  get "inventory", to: "inventory#index"
  post "inventory/adjust", to: "inventory#adjust_stock"
end
