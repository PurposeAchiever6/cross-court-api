module Api
  module V1
    class PurchasesController < Api::V1::ApiUserController
      def index
        @purchases = current_user.purchases.order(id: :desc)
      end
    end
  end
end
