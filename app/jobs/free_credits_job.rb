class FreeCreditsJob < ApplicationJob
  queue_as :default

  def perform
    UsersQuery.new.expired_free_session_users.each do |user|
      user.decrement(:credits)
      user.free_session_state = 'expired'
      user.save!
    end

    UsersQuery.new.free_session_not_used_in(7.days).each do |user|
      KlaviyoService.new.event(Event::FREE_SESSION_NOT_USED_IN_7_DAYS, user)
    end

    UsersQuery.new.free_session_expires_in(15.days).each do |user|
      KlaviyoService.new.event(Event::FREE_SESSION_EXPIRES_SOON, user, expires_in: 15)
    end
  end
end
