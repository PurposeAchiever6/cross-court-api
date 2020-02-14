module Api
  module V1
    class UsersController < Api::V1::ApiUserController
      skip_before_action :authenticate_user!, only: :resend_confirmation_instructions

      def show; end

      def profile
        render :show
      end

      def update
        current_user.update!(user_params)
        render :show
      end

      def resend_confirmation_instructions
        user.send_confirmation_instructions unless user.nil? || user.confirmed?
        head :no_content
      end

      private

      def user
        @user ||= User.find_by(email: params[:email])
      end

      def user_params
        params.require(:user).permit(:name, :phone_number)
      end
    end
  end
end
