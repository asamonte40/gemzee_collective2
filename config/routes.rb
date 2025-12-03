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

  # Root path
  root "products#index"

  # Products and categories
  resources :products, only: [ :index, :show ] do
    collection do
      get "on_sale"
      get "new_products"
      get "recently_updated"
    end
  end
  resources :categories, only: [ :show ]

  # Cart
  get "cart", to: "cart#show"
  post "cart/add/:id", to: "cart#add", as: "add_to_cart"
  patch "cart/update/:id", to: "cart#update", as: "update_cart"
  delete "cart/remove/:id", to: "cart#remove", as: "remove_from_cart"
  delete "cart/clear", to: "cart#clear", as: "clear_cart"

  # Checkout
  get "/checkout", to: "checkout#show", as: :checkout  # for /checkout page without ID
  post "/checkout", to: "checkout#create"              # form submission
  # get "/checkout/success", to: "checkout#success", as: :checkout_success
  get "/checkout/payment/:id", to: "checkout#payment", as: :checkout_payment
  post "/checkout/create_payment_intent", to: "checkout#create_payment_intent"

  # config/routes.rb
  post "create_checkout_session", to: "stripe#checkout"

  post "create_checkout_session", to: "payments#create_checkout_session"
  get "success", to: "payments#success"
  get "cancel", to: "payments#cancel"


  resources :orders, only: [ :index, :show ] do
    member do
      get "confirmation"
    end
  end

  # Pages
  get "pages/:slug", to: "pages#show", as: :page

  # Orders and payments
  resource :payment, only: [ :show, :create ]


  # Search
  get "search", to: "search#index"
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
