class ConfirmUnconfirmedSessionsJob < ApplicationJob
  queue_as :default

  def perform
    UserSessionsQuery.new.finished_cancellation_time.reserved.find_each do |user_session|
      UserSessionAutoConfirmed.new(user_session).save!
    end
  end
end
