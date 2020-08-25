class RemoveExpiredFreeCreditsJob < ApplicationJob
  queue_as :default

  def perform
    UsersQuery.new.expired_free_session_users.each do |user|
      user.decrement(:credits)
      user.free_session_state = 'expired'
      user.save!
    end
  end
end
