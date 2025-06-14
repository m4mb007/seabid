Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  resource :profile, only: [:edit, :update], controller: 'profiles'
  resource :password, only: [:edit, :update], controller: 'passwords'
  
  resources :plate_numbers do
    resources :bids, only: [:new, :create]
    resources :payments, only: [:new, :create]
  end

  resources :payments, only: [] do
    get :thank_you, on: :member
  end

  resources :bidding_fees, only: [:new, :create]
  
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :settings, only: [:index, :update]
    resources :payments, only: [:index, :show]
    resources :plate_numbers
  end
  
  # Stripe webhook
  post 'stripe/webhook', to: 'payments#webhook'
  
  get 'dashboard', to: 'home#dashboard'
  get 'my_bids', to: 'home#my_bids'
  get 'my_payments', to: 'home#my_payments'
  
  root 'home#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Newsletter subscription
  post 'newsletters/subscribe', to: 'newsletters#subscribe', as: :subscribe_newsletter
end
