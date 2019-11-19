Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount_devise_token_auth_for 'User', at: '/api/v1/users', controllers: {
    registrations: 'api/v1/registrations',
    sessions: 'api/v1/devise_sessions',
    passwords: 'api/v1/passwords'
  }

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
        resources :user_sessions, only: [] do
          put :cancel
        end
        resource :user, only: %i[update show] do
          get :profile
          post :resend_confirmation_instructions
        end
      end
    end
  end
end
