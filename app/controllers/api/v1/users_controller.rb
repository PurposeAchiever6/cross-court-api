module Api
  module V1
    class UsersController < Api::V1::ApiUserController
      skip_before_action :authenticate_user!,
                         only: %i[resend_confirmation_instructions update_skill_rating]

      def show; end

      def profile
        render :show
      end

      def update
        current_user.update!(user_params)
        image = params[:user][:image]

        add_image(image) if image.present?

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

      def referrals
        @referrals = Users::GetReferrals.call(user: current_user).list
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

      def add_image(image)
        AddAttachment.call(
          object: current_user,
          column_name: 'image',
          base_64_attachment: image,
          attachment_name: 'profile_image'
        )
      end
    end
  end
end
