Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  # Devise routes for authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'authentication#login'
      post 'auth/logout', to: 'authentication#logout'
      get 'auth/me', to: 'authentication#me'

      # Warehouses
      resources :warehouses do
        member do
          get :qr_code
          get :qr_code_pdf
        end
        resources :items, only: [:index]
      end

      # Items
      resources :items do
        member do
          get :qr_code
          get :qr_code_pdf
          post :checkout
          post :checkin
        end
        collection do
          get :categories
          get :brands
        end
      end

      # Transactions
      resources :transactions, only: [:index, :show, :create, :update] do
        member do
          post :complete
          post :cancel
        end
        collection do
          get :overdue
          get :statistics
        end
      end

      # Search
      get 'search', to: 'search#index'
      get 'search/suggestions', to: 'search#suggestions'
      get 'search/qr/:code', to: 'search#qr_lookup'
      get 'search/filters', to: 'search#filters'

      # QR Code scanning
      post 'qr_scanner/scan', to: 'qr_scanner#scan'
      post 'qr_scanner/quick_action', to: 'qr_scanner#quick_action'
      get 'qr_scanner/history', to: 'qr_scanner#scan_history'
      post 'qr_scanner/bulk_scan', to: 'qr_scanner#bulk_scan'

      # Reports
      namespace :reports do
        get 'dashboard', to: 'dashboard#index'
        get 'warehouse_occupancy', to: 'dashboard#warehouse_occupancy'
        get 'overdue_items', to: 'dashboard#overdue_items'
        get 'item_movements', to: 'dashboard#item_movements'
        get 'export/pdf', to: 'exports#pdf'
        get 'export/excel', to: 'exports#excel'
      end

      # Users (admin only)
      resources :users, only: [:index, :show, :create, :update, :destroy]
    end
  end

  # Web routes (Vue.js SPA will handle these)
  get '/app', to: 'home#app'
  get '/app/*path', to: 'home#app'

  # Direct routes for specific features
  get '/warehouses', to: 'home#app'
  get '/warehouses/*path', to: 'home#app'
  get '/items', to: 'home#app'
  get '/items/*path', to: 'home#app'
  get '/scan', to: 'home#app'
  get '/reports', to: 'home#app'
  get '/reports/*path', to: 'home#app'
  get '/admin', to: 'home#app'
  get '/admin/*path', to: 'home#app'

  # Health check
  get '/health', to: 'application#health'
end
