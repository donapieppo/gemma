Rails.application.routes.draw do
  mount DmUniboCommon::Engine => "/dm_unibo_common", :as => "dm_unibo_common"

  get "/logins/logout", to: "dm_unibo_common/logins#logout"

  get "/stats/organization/:id", to: "stats#organization", as: "organization_stats"
  get "/choose_organization", to: "organizations#choose_organization", as: "choose_organization"

  # cesia list (more than dm_unibo_common)
  get "/organizations", to: "organizations#index", as: "organizations"
  get "/infos", to: "infos#index", as: "infos"
  get "/logins/choose_organization", to: "helps#old_url"
  get "/logins/form", to: "helps#old_url"

  get "/home", to: "home#index", as: "home"
  get "helps", to: "helps#index"

  scope ":__org__" do
    # current_organization implicit
    get "/edit", to: "organizations#edit", as: "current_organization_edit"
    patch "/update", to: "organizations#update", as: "current_organization_update"
    get "/booking_accept", to: "organizations#booking_accept", as: "current_organization_booking_accept"
    post "/start_booking", to: "organizations#start_booking", as: "current_organization_start_booking"

    get "dsausers/popup_find", to: "dsausers#popup_find", as: "popup_find_user"
    post "dsausers/find", to: "dsausers#find", as: "find_user"
    get "reports", to: "reports#index", as: "reports"
    get "reports/ddts/(:id)", to: "reports#ddt", as: "ddt_report"

    %w[index form_articoli form_giacenza form_sottoscorta form_scarichi form_receipts form_storico form_ddts form_orders ddt unavailable form_provision].each do |action|
      get "reports/#{action}", controller: "reports", action: action
    end

    %w[articoli giacenza sottoscorta scarichi receipt storico ddts orders provision bookings].each do |action|
      post "reports/#{action}", controller: "reports", action: action, as: "#{action}_reports"
    end

    # SEARCH
    post "search", to: "search#search", as: "admin_search"
    get "search", to: "groups#index"

    get "helps", to: "helps#index"
    get "helps/contacts", to: "helps#contacts", as: "contacts"

    get "archs", to: "archs#index"
    post "archs/list", to: "archs#list", as: "archs_list"
    post "archs/list_thing", to: "archs#list_thing", as: "archs_list_thing"

    get "/", to: "groups#index", as: "current_organization_root"

    resources :groups do
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

    resources :bookings, except: [:show, :edit, :update] do
      post :confirm, on: :member
      get :barcode, on: :collection, action: :index
      # patch :delete_and_new_unload, on: :member
    end
    resources :users do
      resources :bookings
    end
    resources :delegations

    resources :things do
      post :generate_barcode, on: :member
      collection do
        post :find
        get :find
        get :inactive
      end
      resources :shifts
      resources :takeovers
      resources :stocks
      resources :barcodes
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
        get :find
      end
      resources :ddts
    end

    resources :orders do
      collection do
        get :delivery
      end
    end

    resources :labs
  end

  root to: "groups#index"

  # samrtphone zxing
  get "zxing_search/(:bc)", controller: :barcodes, action: :zxing_search
end
