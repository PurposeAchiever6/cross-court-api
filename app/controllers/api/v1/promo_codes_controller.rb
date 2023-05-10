module Api
  module V1
    class PromoCodesController < Api::V1::ApiUserController
      before_action :check_promo_code

      def show
        @discounted_price = promo_code.apply_discount(price)
      end

      private

      def price
        @price ||= product.price(current_user)
      end

      def product
        @product ||= Product.find(params[:product_id])
      end

      def promo_code
        @promo_code ||= PromoCode.find_by!(code: params[:promo_code])
      end

      def check_promo_code
        @promo_code = PromoCode.find_by(code: params[:promo_code])

        raise PromoCodeInvalidException unless @promo_code

        @promo_code.validate!(current_user, product)
      end
    end
  end
end
