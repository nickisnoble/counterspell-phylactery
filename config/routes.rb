Rails.application.routes.draw do
  resources :heroes
  resources :users, path: "players", except: %w[ index new create destroy ]

  # Dynamic routes for Hero::Descriptor types
  %w[ancestries roles].each do |type|
    resources type.to_sym, controller: "hero/descriptors", type: type.singularize, param: :id, path_names: { new: "new" }
  end

  resource :session do
    get :verify
    post :validate
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "home", to: "pages#home"
  root "pages#index"
end
