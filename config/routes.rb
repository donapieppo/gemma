Rails.application.routes.draw do
  mount DmUniboCommon::Engine => "/dm_unibo_common"

  get '/logins/logout',  to: 'dm_unibo_common/logins#logout'

  get '/stats',                  to: "stats#index", as: "activity"
  get '/stats/organization/:id', to: "stats#organization", as: "organization_stats"
  get '/choose_organization',    to: "organizations#choose_organization", as: "choose_organization"
  get '/no_access',              to: "logins#no_access", as: "no_access"

  # cesia list (more than dm_unibo_common)
  get '/organizations',          to: 'organizations#index', as: "organizations"

  scope ":__org__" do
    # current_organization implicit
    get  '/edit',           to: 'organizations#edit',   as: "current_organization_edit"
    patch '/update',        to: 'organizations#update', as: "current_organization_update"
    get  '/booking_accept', to: 'organizations#booking_accept', as: "current_organization_booking_accept"
    post '/start_booking',  to: 'organizations#start_booking', as: "current_organization_start_booking"

    get 'dsausers/popup_find', to: 'dsausers#popup_find', as: 'popup_find_user'
    get 'dsausers/find',       to: 'dsausers#find',       as: 'find_user'
    get 'reports',             to: "reports#index",       as: 'reports'
    get 'reports/ddts/(:id)',  to: "reports#ddt",         as: 'ddt_report'

    %w(index form_articoli form_giacenza form_sottoscorta form_scarichi form_receipts form_storico form_ddts form_orders ddt unavailable form_provision).each do |action|
      get "reports/#{action}", controller: 'reports', action: action
    end

    %w(articoli giacenza sottoscorta scarichi receipt storico ddts orders provision).each do |action|
      post "reports/#{action}", controller: 'reports', action: action
    end
    
    # SEARCH
    post 'search', to: 'search#search', as: 'admin_search'
    get  'search', to: 'groups#index'

    get  'helps/contacts',      to: 'helps#contacts', as: 'contacts'
    get  'helps/index',         to: 'helps#index'

    get  'archs',               to: 'archs#index'
    post 'archs/list',          to: 'archs#list'
    post 'archs/list_thing',    to: 'archs#list_thing'

    get '/',              to: 'groups#index', as: 'current_organization_root'

    resources :groups  do
      resources :things
      resources :stocks
    end

    resources :locations do 
      member do 
        get :destroy_form
      end
      resources :things
    end

    resources :deposits do 
      resources :moves
    end
    resources :barcodes
    resources :loads
    resources :prices
    resources :stocks do
      collection do
        post :create_from_array
      end
    end
    resources :takeovers
    resources :operations
    resources :shifts
    resources :unloads do
      member do
        get :signing
      end
    end 

    resources :bookings do
      post :barcode, on: :collection, action: :index
      get :confirm, on: :member
    end
    resources :users do
      resources :bookings
    end
    resources :delegations

    resources :things do
      collection do 
        post :find 
        get  :find
        get  :inactive
      end
      resources :shifts
      resources :takeovers
      resources :stocks
      resources :barcodes do
        post :generate, on: :collection
      end
      resources :deposits
      resources :unloads
      resources :loads
      resources :bookings
      resources :prices
      resources :moves, only: :index
      resources :images
      resources :thingcodes do
        collection do
          get :supplier
        end
      end
      get :recalculate_prices, on: :member
    end

    resources :images

    resources :ddts do
      collection do 
        post :search
        post :search_cia
      end
    end

    resources :suppliers do
      collection do
        post :find
        get  :find
      end
      resources :ddts
    end

    resources :orders do
      collection do
        get :delivery
      end
    end

    resources :thingcodes 

  end

  root to: 'groups#index'

  # samrtphone zxing
  get "zxing_search/(:bc)", controller: :barcodes, action: :zxing_search
end

