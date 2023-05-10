module Api
  module V1
    class ProductsController < Api::V1::ApiController
      def index
        @products = Product.for_user(current_user)
                           .order(:order_number)
                           .includes(:promo_code, image_attachment: :blob)
      end
    end
  end
end
