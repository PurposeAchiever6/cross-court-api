class KlaviyoCheckInUsers
  include Sidekiq::Worker

  def perform(checked_in_ids)
    klaviyo_service = KlaviyoService.new
    UserSession.where(id: checked_in_ids).includes(:user).each do |user_session|
      if user_session.is_free_session
        klaviyo_service.event(Event::FREE_SESSION_CHECK_IN, user_session.user)
      else
        klaviyo_service.event(Event::SESSION_CHECK_IN, user_session.user)
      end
    end
  end
end
