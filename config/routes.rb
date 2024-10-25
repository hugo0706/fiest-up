# frozen_string_literal: true

Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"
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
    get "/login", to: "sessions#login", as: "login"
    get "/callback", to: "sessions#callback"
  end

  namespace :party_data do
    scope "/:code" do
      scope "/settings" do
        get "/device_list", to: "settings#device_list", as: "party_device_list"
        post "/party_device", to: "settings#party_device", as: "set_party_device"
      end
      scope "/queue" do
        post "/add", to: "queues#add_song_to_queue", as: "add_to_queue"
      end
      get "/search", to: "search#search", as: "search"
    end
  end

  scope "/party" do
    post "/start/:code", to: "parties#start", as: "start_party"
    get "/:code/select_device", to: "parties#select_device", as: "select_device"
    get "/settings/:code", to: "parties#settings", as: "party_settings"
    get "/join/:code", to: "parties#join", as: "join_party"
    post "/create", to: "parties#create", as: "create_party"
    get "/list", to: "parties#index", as: "party_list"
    get "/:code", to: "parties#show", as: "show_party"
  end
  
  scope '/accounts' do
    get '', to: "accounts#index", as: "account_settings"
    post '/destroy', to: "accounts#destroy", as: "account_destroy"
  end

  resources :temporal_sessions, only: [ :create, :destroy ]

  get "/home", to: "home#index"

  match "*unmatched", to: "application#not_found_method", via: :all
end
