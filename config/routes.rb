Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  get "impressum", to: "pages#impressum", as: :impressum
  get "datenschutz", to: "pages#datenschutz", as: :datenschutz
  get "fahrzeuge", to: "pages#fahrzeuge", as: :fahrzeuge

  # Double-Opt-In Waitlist
  post "waitlist", to: "waitlist#create", as: :waitlist
  get "waitlist/confirm/:token", to: "waitlist#confirm", as: :confirm_waitlist

  # Admin
  namespace :admin do
    get "/", to: "waitlist#index"
    resources :waitlist, only: :index
  end
end
