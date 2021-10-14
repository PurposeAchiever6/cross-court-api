class InactiveUsersJob < ApplicationJob
  queue_as :default

  def perform
    User.includes(
      :last_checked_in_user_session,
      :first_future_user_session,
      :active_subscription
    ).no_credits.find_each do |user|
      last_session = user.last_checked_in_user_session

      next unless last_session && !user.first_future_user_session
      next if user.active_subscription

      today_date = Time.zone.today

      case last_session.date
      when today_date - 14.days
        SlackService.new(user).inactive_first_timer_user if last_session.is_free_session
      when today_date - 1.month
        SlackService.new(user).inactive_user
      end
    end
  end
end
