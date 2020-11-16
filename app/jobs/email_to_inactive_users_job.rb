class EmailToInactiveUsersJob < ApplicationJob
  queue_as :default

  def perform
    User.includes(:last_checked_in_user_session, :first_future_user_session).no_credits.find_each do |user|
      if user.last_checked_in_user_session&.date == Time.zone.today - 14.days && !user.first_future_user_session
        KlaviyoService.new.event(Event::TIME_TO_RE_UP, user)
      end
    end
  end
end
