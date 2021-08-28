module Api
  module V1
    class PromoCodesController < Api::V1::ApiUserController
      before_action :check_promo_code
      def show
        render json: { price: promo_code.apply_discount(price) }, status: :ok
      end

      private

      def price
        @price ||= product.price
      end

      def product
        @product ||= Product.find(params[:product_id])
      end

      def promo_code
        @promo_code ||= PromoCode.find_by!(code: params[:promo_code])
      end

      def check_promo_code
        return if promo_code&.still_valid?(current_user) && promo_code.product == product

        raise PurchaseException, I18n.t('api.errors.promo_code.invalid')
      end
    end
  end
end
