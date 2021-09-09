class KlaviyoCheckInUsers
  include Sidekiq::Worker

  def perform(checked_in_ids)
    klaviyo_service = KlaviyoService.new
    UserSession.where(id: checked_in_ids).includes(:user).each do |user_session|
      event = user_session.is_free_session ? Event::FREE_SESSION_CHECK_IN : Event::SESSION_CHECK_IN
      klaviyo_service.event(event, user_session.user)
    end
  end
end
