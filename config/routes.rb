Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :products
  resources :suppliers
  resources :locations
  resources :purchase_orders


  # Sales transactions - using custom routes for better UX
  get "sales", to: "sales#index"
  post "sales", to: "sales#create"
  get "sales/new", to: "sales#new", as: :new_sale
  get "sales/:id", to: "sales#show", as: :sale
  delete "sales/:id", to: "sales#destroy"

  # Dashboard and other pages
  get "dashboard", to: "dashboard#index"
  root "dashboard#index"

  get "inventory", to: "inventory#index"
  post "inventory/adjust", to: "inventory#adjust_stock"

  get "forecasting", to: "forecasting#index"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
