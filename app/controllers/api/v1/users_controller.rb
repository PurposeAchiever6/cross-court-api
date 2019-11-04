module Api
  module V1
    class UsersController < Api::V1::ApiController
      def show; end

      def profile
        render :show
      end

      def update
        current_user.update!(user_params)
        render :show
      end

      private

      def user_params
        params.require(:user).permit(:name, :phone_number, :email)
      end
    end
  end
end
