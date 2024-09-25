# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", :as => :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", :as => :pwa_manifest

  # Defines the root path route ("/")
  root "start_page#index", as: :start

  namespace :oauth do
    get "/login", to: "sessions#login", as: 'login'
    get "/callback", to: "sessions#callback"
  end

  scope '/party' do
    get '/join/:code', to: "parties#join", as: 'join_party'
    post '/create', to: "parties#create", as: 'create_party'
    get '/list', to: "parties#index", as: 'party_list'
    get '/:code', to: "parties#show", as: 'show_party'
  end
  
  resources :temporal_sessions, only: :create

  get "/home", to: "home#index"
  
  match '*unmatched', to: 'application#not_found_method', via: :all
end
