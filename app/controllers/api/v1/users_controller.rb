module Api
  module V1
    class UsersController < Api::V1::ApiUserController
      skip_before_action :authenticate_user!,
                         only: %i[
                           resend_confirmation_instructions
                           update_skill_rating
                           update_personal_info
                           send_membership_handbook
                         ]

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
        skill_rating = skill_rating_params[:skill_rating]

        Users::UpdateSkillRating.call(user: user_to_update, skill_rating:)

        head :ok
      end

      def update_personal_info
        personal_info = personal_info_params

        Users::UpdatePersonalInfo.call(user:, personal_info:)

        head :ok
      end

      def request_update
        reason = params[:reason]
        requested_attributes = requested_attributes_params

        Users::UpdateRequest.call(
          user: current_user,
          requested_attributes:,
          reason:
        )

        head :ok
      end

      def resend_confirmation_instructions
        user.send_confirmation_instructions unless user.confirmed?
        head :no_content
      end

      def referrals
        @referrals = Users::GetReferrals.call(user: current_user).list
      end

      def send_membership_handbook
        email = params[:email]

        UserMailer.with(email:).membership_handbook.deliver_later

        head :ok
      end

      private

      def user
        @user ||= User.find_by!(email: params[:email])
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :phone_number,
          :instagram_username,
          :birthday,
          :gender,
          :apply_cc_cash_to_subscription
        )
      end

      def skill_rating_params
        params.require(:user).permit(:skill_rating)
      end

      def personal_info_params
        params.require(:personal_info).permit(
          :weight,
          :height,
          :competitive_basketball_activity,
          :current_basketball_activity,
          :position,
          :main_goal,
          goals: []
        )
      end

      def requested_attributes_params
        params.permit(:skill_rating)
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
