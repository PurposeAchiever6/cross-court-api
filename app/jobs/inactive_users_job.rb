class InactiveUsersJob < ApplicationJob
  queue_as :default

  def perform
    User.includes(:last_checked_in_user_session, :first_future_user_session).no_credits.find_each do |user|
      last_session_date = user.last_checked_in_user_session&.date

      next unless last_session_date && !user.first_future_user_session

      today_date = Time.zone.today

      case last_session_date
      when today_date - 7.days
        KlaviyoService.new.event(Event::TIME_TO_RE_UP_1, user)
      when today_date - 14.days
        KlaviyoService.new.event(Event::TIME_TO_RE_UP_2, user)
      when today_date - 1.month
        SlackService.new(user).inactive_user
      end
    end
  end
end
