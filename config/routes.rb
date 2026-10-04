Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "storefront#show"
  get "catalog", to: "catalog#index"
  resources :categories, only: :show, param: :slug
  resources :products, only: :show, param: :slug
  resources :posts, only: %i[index show], param: :slug
  resources :inquiries, only: %i[new create]
  resource :cart, only: :show
  resources :cart_items, only: %i[create update destroy]
  resource :checkout, only: %i[new create] do
    get "success/:number", action: :success, as: :success
  end
  ActiveAdmin.routes(self)
  direct(:admin) { admin_root_path }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "robots.txt", to: "seo#robots", defaults: { format: :text }
  get "sitemap.xml", to: "seo#sitemap", defaults: { format: :xml }

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
