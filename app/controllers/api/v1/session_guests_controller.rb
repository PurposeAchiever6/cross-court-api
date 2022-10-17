module Api
  module V1
    class SessionGuestsController < Api::V1::ApiUserController
      def create
        @session_guest = SessionGuests::Add.call(
          user_session: user_session,
          guest_info: params[:guest_info]
        ).session_guest
      end

      def destroy
        SessionGuests::Remove.call(
          user_session: user_session,
          session_guest_id: params[:id]
        )

        head :ok
      end

      private

      def user_session
        current_user.user_sessions.find(params[:user_session_id])
      end
    end
  end
end
