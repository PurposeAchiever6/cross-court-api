class ConfirmUnconfirmedSessionsJob < ApplicationJob
  queue_as :default

  def perform
    klaviyo_service = KlaviyoService.new
    UserSessionsQuery.new.finished_cancellation_time.reserved.find_each do |user_session|
      user_session.confirmed!
      klaviyo_service.event(
        Event::SESSION_CONFIRMATION,
        user_session.user,
        user_session: user_session
      )
    end
  end
end
