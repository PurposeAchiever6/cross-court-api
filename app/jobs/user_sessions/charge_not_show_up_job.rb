module UserSessions
  class ChargeNotShowUpJob < ApplicationJob
    queue_as :default

    def perform
      UserSession.not_open_club
                 .for_yesterday
                 .confirmed
                 .not_checked_in
                 .no_show_up_fee_not_charged
                 .includes(:user)
                 .find_each do |user_session|
        UserSessions::ChargeNoShow.call(user_session:)
        user_session.update!(state: :no_show)
      end
    end
  end
end
