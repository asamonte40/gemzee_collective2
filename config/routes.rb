Rails.application.routes.draw do
  # get "pages/about"
  # get "pages/contact"
  # get "orders/index"
  # get "orders/show"
  # get "payments/show"
  # get "payments/create"
  # get "checkout/new"
  # get "checkout/create"
  # get "cart/show"
  # get "cart/add"
  # get "cart/update"
  # get "cart/remove"
  # get "cart/clear"
  # get "search/index"
  # get "categories/show"
  # get "products/index"
  # get "products/show"
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "products#index"

  resources :products, only: [ :index, :show ]
  resources :categories, only: [ :show ]

  get "products/on_sale", to: "products#on_sale"
  get "products/new_products", to: "products#new_products"
  get "products/recently_updated", to: "products#recently_updated"

  get "cart", to: "cart#show"
  post "cart/add/:id", to: "cart#add", as: "add_to_cart"
  patch "cart/update/:id", to: "cart#update", as: "update_cart"
  delete "cart/remove/:id", to: "cart#remove", as: "remove_from_cart"
  delete "cart/clear", to: "cart#clear", as: "clear_cart"

  get "checkout", to: "checkout#new"
  post "checkout", to: "checkout#create"

  get "pages/:slug", to: "pages#show", as: :page

  resources :orders, only: [ :index, :show ]
  resources :payments, only: [ :show, :create ]

  get "search", to: "search#index"
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
