module Api
  module V1
    class PromoCodesController < Api::V1::ApiUserController
      before_action :check_promo_code

      def show
        render json: { price: promo_code.apply_discount(price) }, status: :ok
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

        raise PurchaseException, I18n.t('api.errors.promo_code.invalid') if @promo_code.nil? || !@promo_code.for_product?(product)
        raise PurchaseException, I18n.t('api.errors.promo_code.no_longer_valid') if @promo_code.expired? || @promo_code.max_times_used?
        raise PurchaseException, I18n.t('api.errors.promo_code.already_used') if @promo_code.max_times_used_by_user?(current_user)
      end
    end
  end
end
