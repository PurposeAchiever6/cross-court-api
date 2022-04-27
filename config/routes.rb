Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad

  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount_devise_token_auth_for 'User', at: '/api/v1/users', controllers: {
    registrations: 'api/v1/registrations',
    confirmations: 'api/v1/confirmations',
    sessions: 'api/v1/devise_sessions',
    passwords: 'api/v1/passwords'
  }

  root to: 'admin/scheduler#index'

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      namespace :sonar do
        post :webhook
      end
      namespace :stripe do
        post :webhook
      end
      devise_scope :user do
        get :status, to: 'api#status'
        resource :promo_code, only: :show
        resources :legals, only: :show, param: :title
        resources :locations, only: :index
        resources :gallery_photos, only: :index
        resources :sessions, only: %i[index show] do
          scope module: :sessions do
            resources :user_sessions, only: %i[create index]
            resource :waitlists, only: %i[create destroy]
          end
        end
        resources :products, only: :index
        resources :user_sessions, only: :index do
          put :cancel
          put :confirm
        end
        resources :purchases, only: %i[create index] do
          put :create_free_session_intent, on: :collection
        end
        resources :payment_methods, only: %i[create index destroy update]
        resource :user, only: %i[update show] do
          get :profile
          post :resend_confirmation_instructions
          put :update_skill_rating
          get :referrals
        end
        namespace :sem do
          resources :sessions, only: :show
        end
        resources :session_surveys, only: [] do
          get :questions, on: :collection
          post :answers, on: :collection
        end
        resources :subscriptions, except: %i[show new edit] do
          member do
            post :reactivate
            post :payment_method, action: :change_payment_method
            put :pause
            put :unpause
          end
          collection do
            post :feedback
            get :preview_prorate
          end
        end
        namespace :active_campaign do
          resources :deals, only: %i[create]
          resources :contacts, only: %i[create]
        end
      end
    end
  end
end
