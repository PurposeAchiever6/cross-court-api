class UserSessionConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    user_session.state = :confirmed unless in_cancellation_time?
    user_session.save!
  end
end
