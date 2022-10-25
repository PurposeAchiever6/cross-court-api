module UserSessions
  class ConfirmUnconfirmedJob < ApplicationJob
    queue_as :default

    def perform
      relation = UserSession.reserved

      UserSessionsQuery.new(relation).finished_cancellation_time.find_each do |user_session|
        UserSessions::AutoConfirm.call(user_session: user_session)
      end
    end
  end
end
