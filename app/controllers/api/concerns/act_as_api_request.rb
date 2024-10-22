module Api
  module Concerns
    module ActAsApiRequest
      extend ActiveSupport::Concern

      included do
        skip_before_action :verify_authenticity_token
        before_action :skip_session_storage
        before_action :check_json_request
      end

      def check_json_request
        return if request_content_type&.match?(/json/)

        render json: { error: I18n.t('api.errors.invalid_content_type') }, status: :not_acceptable
      end

      def skip_session_storage
        # Devise stores the cookie by default, so in api requests, it is disabled
        # http://stackoverflow.com/a/12205114/2394842
        request.session_options[:skip] = true
      end

      def render_error(status, message, _data = nil)
        response = {
          error: message
        }
        render json: response, status:
      end

      def request_content_type
        request.headers['Content-Type']
      end
    end
  end
end
