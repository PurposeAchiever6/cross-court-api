module Api
  module V1
    class SubscriptionsController < Api::V1::ApiController
      def create
        ActiveRecord::Base.transaction do
          stripe_service.create_subscription(product)
        end
        head :ok
      end

      private

      def stripe_service
        @stripe_service ||= StripeService.new(current_user, params[:payment_method])
      end

      def product
        @product ||= Product.find_by!(stripe_id: params[:stripe_product_id])
      end
    end
  end
end
