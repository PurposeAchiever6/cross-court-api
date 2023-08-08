module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :exception
      include Api::Concerns::ActAsApiRequest

      def create
        ActiveRecord::Base.transaction do
          super do |user|
            Users::CreateExternalIntegrations.call(user:)
            Users::ResendVerificationEmailJob.set(wait: 48.hours).perform_later(user.id)
          end
        end
      rescue StandardError => e
        Rollbar.error(e)
        render_error(:conflict, I18n.t('api.errors.users.registration.communication'))
      end

      private

      def sign_up_params
        params.require(:user)
              .permit(:email, :utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content)
      end

      def render_create_success
        render json: { user: resource_data }
      end
    end
  end
end
