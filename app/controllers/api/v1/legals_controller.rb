module Api
  module V1
    class LegalsController < ApiController
      def show
        legal = Legal.find_by(title:)
        render json: { text: legal.text }, status: :ok
      end

      private

      def title_options
        %w[terms_and_conditions cancelation_policy]
      end

      def title_param
        @title_param ||= params[:title]
      end

      def title
        return title_param if title_options.include?(title_param)

        raise WrongParameterException, I18n.t('api.errors.legal')
      end
    end
  end
end
