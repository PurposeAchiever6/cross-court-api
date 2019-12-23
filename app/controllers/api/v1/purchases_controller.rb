module Api
  module V1
    class PurchasesController < Api::V1::ApiUserController
      def index
        @purchases = current_user.purchases.order(id: :desc)
      end

      def create
        StripeService.charge(current_user, params[:payment_method], product)
      end

      private

      def product
        Product.find(params[:product_id])
      end
    end
  end
end
