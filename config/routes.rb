Rails.application.routes.draw do
  devise_for :users
  
  resources :plate_numbers do
    resources :bids, only: [:new, :create]
    resources :payments, only: [:new, :create]
  end

<<<<<<< Updated upstream
  resources :bidding_fees, only: [:new, :create]
  
  namespace :admin do
    resources :payments, only: [:index, :show]
=======
  resources :payments, only: [:index, :show] do
    collection do
      post :webhook
    end
    member do
      get :thank_you
    end
  end

  resources :bidding_fees, only: [:new] do
    collection do
      get :success
      get :cancel
    end
  end
  
  namespace :admin do
    root to: 'dashboard#index'
    resources :users
    resources :plate_numbers
    resources :bids
    resources :payments
    get 'settings', to: 'settings#index'
>>>>>>> Stashed changes
  end
  
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
end
