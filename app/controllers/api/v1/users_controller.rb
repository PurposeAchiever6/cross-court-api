module Api
  module V1
    class UsersController < Api::V1::ApiUserController
      skip_before_action :authenticate_user!, only: %i[resend_confirmation_instructions update_skill_rating]

      def show; end

      def profile
        render :show
      end

      def update
        current_user.update!(user_params)
        render :show
      end

      def update_skill_rating
        user_to_update = current_user || user
        user_to_update.update!(skill_rating_params)
        head :ok
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
        params.require(:user).permit(:first_name, :last_name, :phone_number)
      end

      def skill_rating_params
        params.require(:user).permit(:skill_rating)
      end
    end
  end
end
