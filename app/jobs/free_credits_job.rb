class FreeCreditsJob < ApplicationJob
  queue_as :default

  def perform
    UsersQuery.new.expired_free_session_users.each do |user|
      user.decrement(:credits)
      user.free_session_state = 'expired'
      user.save!
    end

    UsersQuery.new.free_session_not_used_in_7_days.each do |user|
      KlaviyoService.new.event(Event::FREE_SESSION_NOT_USED_IN_7_DAYS, user)
    end
  end
end
