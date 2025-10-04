Rails.application.routes.draw do
  # Authentication routes
  get "signup", to: "registrations#new"
  post "signup", to: "registrations#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  get "confirmations/:token", to: "confirmations#show", as: :confirmation

  resources :password_resets, only: [ :new, :create, :edit, :update ]

  # Settings
  resource :settings, only: [ :edit, :update ]

  # Invites
  resources :invites, only: [ :new, :create ]

  # Direct Messages
  resources :dms, only: [ :new, :create ]

  # Messages (for reactions)
  resources :messages, only: [] do
    resources :reactions, only: [ :create ]
    member do
      get :reactions_partial
    end
  end

  # Channels
  resources :channels, only: [ :index, :new, :create, :show, :edit, :update ] do
    resources :messages, only: [ :create, :show, :update, :destroy ] do
      member do
        get :thread
        get :thread_indicator
      end
    end
    resources :members, only: [ :index, :create, :update, :destroy ]
    resource :favorite, only: [ :create, :destroy ]
    collection do
      get :browse
    end
    member do
      post :archive
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "channels#index"
end
