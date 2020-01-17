module Api
  module V1
    class ProductsController < Api::V1::ApiController
      def index
        @products = Product.order(:order_number).includes(image_attachment: :blob)
      end
    end
  end
end
