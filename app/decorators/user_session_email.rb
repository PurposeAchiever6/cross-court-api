class UserSessionEmail
  delegate_missing_to :user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    user_session.save!
    SessionMailer.delay.new_session(user, session, user_session.date, user_session.id)
  end
end
