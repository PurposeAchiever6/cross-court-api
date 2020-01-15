Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount_devise_token_auth_for 'User', at: '/api/v1/users', controllers: {
    registrations: 'api/v1/registrations',
    sessions: 'api/v1/devise_sessions',
    passwords: 'api/v1/passwords'
  }

  root to: 'admin/dashboard#index'

  namespace :webhooks, defaults: { format: :json } do
    post :stripe, to: 'stripe#events'
  end

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      devise_scope :user do
        get :status, to: 'api#status'
        resources :locations, only: :index
        resources :sessions, only: %i[index show] do
          scope module: :sessions do
            resources :user_sessions, only: :create
          end
        end
        resources :products, only: :index
        resources :user_sessions, only: :index do
          put :cancel
          put :confirm
        end
        resources :purchases, only: %i[create index] do
          put :claim_free_session, on: :collection
        end
        resources :payment_methods, only: %i[create index destroy]
        resource :user, only: %i[update show] do
          get :profile
          post :resend_confirmation_instructions
        end
        namespace :sem do
          resources :sessions, only: :show
          resources :user_sessions, only: [] do
            put :check_in, on: :collection
          end
        end
      end
    end
  end
end
