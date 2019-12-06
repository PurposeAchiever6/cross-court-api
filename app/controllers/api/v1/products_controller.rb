module Api
  module V1
    class ProductsController < Api::V1::ApiController
      def index
        @products = Product.all
      end
    end
  end
end
