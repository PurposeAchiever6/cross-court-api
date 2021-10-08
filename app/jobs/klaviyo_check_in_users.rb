class KlaviyoCheckInUsers
  include Sidekiq::Worker

  def perform(checked_in_ids)
    klaviyo_service = KlaviyoService.new
    UserSession.where(id: checked_in_ids).includes(:user).each do |user_session|
      user = user_session.user
      event = user_session.is_free_session ? Event::FREE_SESSION_CHECK_IN : Event::SESSION_CHECK_IN
      klaviyo_service.event(event, user)
      KlaviyoService.new.event(Event::TIME_TO_RE_UP_1, user) if send_time_to_re_up?(user)
    end
  end

  def send_time_to_re_up?(user)
    user.subscription_credits.zero? && user.active_subscription.present?
  end
end
