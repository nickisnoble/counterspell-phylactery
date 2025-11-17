Rails.application.routes.draw do
  resources :pages

  root "sessions#new"

  resources :events, only: [ :index, :show ] do
    resources :event_emails, only: [ :show ]
    resources :games, only: [ :show ] do
      resources :seats, only: [ :new, :create, :show ] do
        get :success, on: :collection
      end
    end
  end

  resources :locations, only: [ :index, :show ]

  resources :users, path: "players", except: %w[ index new create destroy ] do
    resources :seats, only: [ :index, :show ], controller: "users/seats"
  end

  resource :dashboard, only: :show

  resources :heroes

  # Stripe webhooks
  post "/stripe/webhooks" => "stripe_webhooks#create"

  # Checkin system
  resource :checkin, only: [:show, :create]
  resources :seats, only: [] do
    member do
      patch :checkin, to: "checkins#update"
    end
  end

  namespace :dashboard do
    resources :locations
    resources :events
    resources :traits
    resources :newsletters
  end

  # Public newsletter routes
  resources :newsletters, only: [:show]

  # Unsubscribe route
  resource :unsubscribe, only: [:show, :create]

  resource :session do
    get :verify
    post :validate
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  mount ActiveHashcash::Engine, at: "hashcash"
  mount ActionCable.server => "/cable"
  get "up" => "rails/health#show", as: :rails_health_check
end
