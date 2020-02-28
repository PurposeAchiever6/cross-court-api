module Api
  module V1
    class PromoCodesController < Api::V1::ApiController
      def show
        new_price = promo_code.present? ? promo_code.apply_discount(price) : price
        render json: { price: new_price }, status: :ok
      end

      private

      def price
        @price ||= params[:price].to_i
      end

      def promo_code
        @promo_code ||= PromoCode.find_by!(code: params[:promo_code])
      end
    end
  end
end
