Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  mount TestAccounts::Engine => "/test_accounts"
  # API Routes
  # V1 API ROUTES
  scope module: :api, defaults: { format: "json" } do
    namespace :v1 do
      post "/request_token" => "tokens#request_token"
      post "/authenticate_token" => "tokens#authenticate_token"
      post '/multi_account_login' => 'tokens#multi_account_login'

      # These routes keep alive old authenticate endpoints
      # that only supported phone numbers
      # TODO - remove these routes once front end is stable
      post "/request_sms_token" => "tokens#request_token"
      post "/authenticate_sms_token" => "tokens#authenticate_token"

      resources :patients, :only => [:index, :show, :update, :create] do
        resources :visits
      end
      resources :providers, only: [:show, :create, :update]
      resources :coordinators, only: [:show, :create, :update]

      resources :organizations, module: "organizations" do
        resources :pooled_available_times, only: [:index]
        resources :provider_available_times, only: [:index]
      end
      resources :available_times, :only => [:index]
      resources :payment_methods, :only => [:index, :create]
      resources :medications, :only => [:create, :index, :destroy]
      resources :legal_releases, :only => [:create]
      resources :visits, :only => [:create, :show, :index, :update], module: "visits" do
        resources :medications, :only => [:create, :index]
        resources :conditions, :only => [:create, :index]
        collection do
          post "history" => "history#create"
          resource :right_now, only: [:create], as: :right_now_visit
        end
      end
      resources :organizations, module: "organizations" do
        resources :providers, only: [:index]
        resources :recordings, only: %i[index show]
      end
      get "/ping"             => "api_pings#ping"
      post "/ping_app_token"  => "api_pings#ping_token"
    end
  end

  resources :twilio, only: [] do
    post :connect_customer, on: :collection
    post :status, on: :collection
  end

  resources :api_docs, only: %i[index show]

  mount StripeEvent::Engine, at: '/stripe_events'

  get '/demo' => 'demo/sign_ups#new', as: :demo_visit

  resources :demo, only: %i[new create], module: "demo" do
    collection do
      resources :sign_ups, only: %i[new create], as: 'demo_sign_ups'
      resources :token_confirmations, only: %i[new create], as: 'demo_token_confirmations'
    end
  end

  get "/demo" => "visits#demo"
  # END API ROUTES

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }, skip: [:registrations]

  root "pages#homepage"

  resources :authentications, only: [:new, :create, :destroy] do
    collection do
      post :verify
      get :verify
      get :multiple
      post :create_with_user
    end
  end

  resources :plans, only: [] do
    get :submit_request, on: :collection
  end

  get "/login"        => "authentications#new", as: :login
  get "/logout"       => "authentications#destroy", as: :logout

  resources :organizations, module: "organizations" do
    member do
      get :landing
    end
    resources :organization_states
    resources :providers do
      get 'get_providers', on: :collection
      post 'update_provider_state', on: :member
      get 'search', on: :collection, to: 'providers/search#index'
      resources :available_times
    end
    resources :patients do
      get 'search', on: :collection, to: 'patients/search#index'
      member do
        get "dashboard"
        get "immediate"
        get "waiting"
      end
      resources :build, controller: "patients/build"
      resources :visits, only: [:index]
      resources :payment_methods, controller: "patients/payment_methods", only: [:index, :create]

      scope module: :patients do
       resources :pre_tests, only: %i[index new show update]
      end
    end
    resources :sign_ups, module: "sign_ups", only: [:new, :create] do
      resources :token_confirmations, only: %i[new create], constraints: { sign_up_id: /[^\/]+/}
    end
    resources :coordinators do
      get 'search', on: :collection, to: 'coordinators/search#index'
    end
    resources :org_admins
    resources :visits do
      get 'get_diagnosis', on: :collection
      get 'search', on: :collection, to: 'visits/search#index'
      member do
        patch :cancel
        get :refresh
        get :conclude
        get :conclude_demo
        post :permission_details
        get :voip_call
      end
      resources :legal_releases, only: [:new, :create]
      resources :build, controller: "visits/build" do
        post 'create_incident_info', on: :member
      end
      resources :completions
      collection do
        get :new_wi
        resources :right_now_visits, only: [:new, :create], module: "visits"
      end
      resources :invitations, only: %i[new create], module: 'visits'
      resources :demo_invitations, only: %i[new create], module: 'visits'
      resources :confirm_phone, only: %i[create]
    end
    resources :org_settings
    resources :marketing_settings
    resources :visit_settings, only: [:index, :update]
    resources :metadata_settings, only: [:index, :update]
    resources :visit_orders, only: [:new, :create] do
      collection do
        get 'search_user'
        get 'show_schedule'
        get :patient
      end
    end
    resources :patient_imports, only: [:index, :create]
    resources :export_visits, only: [:index, :create]
    resources :video_call_settings, only: [:index]
    resources :export_patients, only: [:index, :create]
    resources :archived_users, only: [:index]
    resources :email_reminder_settings, only: [:index, :update]
    resources :sms_reminder_settings, only: [:index, :update]
    resources :payment_methods, only: [:index, :create]
    resources :dashboard, only: [:index]
    resources :subscriptions, only: [:index, :new, :create]
    resources :payouts, only: [:index, :create]
    resources :access_tokens, only: [:index, :update]
    resources :recordings, only: [:index, :show]
    resources :pre_tests, only: %i[index update]
    resources :user_imports, only: [:index, :create, :show] do
      member do
        post :refresh
        post :cancel
        post :import_failures
      end
    end
    resources :users, only: %i[index]
    resource :buckets, only: %i[show edit update destroy] do
      collection do
        get :copy_old_videos
        get :confirm_to_copy
      end
    end
    get "stripe_connect/authorize" => "stripe_connect#index"
    delete "stripe_connect/deauthorize" => "stripe_connect#destroy"
    get "import_form" => "import_data#import_form"
    post "preview" => "import_data#preview"
    post "import_csv_data" => "import_data#import_csv_data"
    post :bulk_import, to: 'import_data#bulk_import'
  end

  resources :users, only: %i[], module: "users" do
    resource :archive, only: %i[create], controller: "archive"
    resource :unarchive, only: %i[destroy], controller: "unarchive"
  end

  resources :users, only: [] do
    collection do
      get :edit
      post :enable_notifications
    end

    member do
      patch :update
    end
  end

  resources :available_times

  resources :visits do
    collection do
      get :billing
      resources :recordings, only: [:create, :show],  module: "visits"
    end
    member do
      put :charge
    end
    resources :video_logs, only: %i[create], module: 'visits'
  end

  resources :visit_settings, only: [:update]
  resources :organizations
  resources :org_admins

  resources :administrators do
    collection do
      get :manage
      get :login
    end
  end

  resources :visit_types
  resources :dependents
  resources :medications
  resources :conditions

  namespace :emails do
    resources :contact_us, only: [:create]
    post '/admin_assistance', to: 'contact_us#admin_assistance'
  end

  resources :org_setups, only: [:new, :create], module: "org_setups" do
    collection do
      resources :sign_ups, only: [:new, :create], as: "org_setup_sign_ups"
      resources :token_confirmations, only: [:new, :create], as: "org_setup_token_confirmations"
    end
    resources :plan_selections, only: [:new, :create]
    resources :basic_details, only: [:new, :create]
    resources :marketing_settings, only: [:new, :create, :show]
    resources :providers, only: [:new, :create]
    resources :visit_settings, only: [:new, :create]
    resources :metadata_settings, only: [:new, :create]
    resources :metadata_settings, only: [:new, :create]
    resources :patient_imports, only: [:new, :create]
    resources :confirm_subscription_plans, only: [:new, :create]
  end

  # page routes
  get "/setup"        => "org_setups/org_setups#new"
  get "/video_demo"   => "pages#visit_demo"
  get "/system"       => "pages#system"
  post "/send_login"  => "patients#send_login"
  get "/contact"      => "pages#contact"
  get "/browser"      => "pages#browser"
  get "/rmg"          => "pages#rmg"

  resources :updates

  # end page routes

  namespace :api do
    get "/visits/:visit_id/overview_data" => "visits#overview_data"
    post "/visits/:visit_id/start"        => "visits#start"
    post "/visits/:visit_id/end"          => "visits#end"
  end

  mount ActionCable.server => "/cable"
  post "api/pusher/auth" => "pusher#auth"

  # BEGING External Redirects
  get "/android" => redirect("https://play.google.com/store/apps/details?id=com.uvo_health"), :as => :android
  get "/ios" => redirect("https://apps.apple.com/us/app/uvo-health-telemedicine/id1455238742"), :as => :ios
  # END External Redirects

  get 's/v/:visit_id', to: "short_urls#visit", as: :visit_short
  get 's/nv', to: "short_urls#new_visit", as: :new_visit_short

  get "/:id", to: "organizations/organizations#show"
  get "/:organization_id/providers", to: "providers#index"

  match '*path', to: 'errors#not_found', via: :all
end
