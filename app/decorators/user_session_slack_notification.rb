class UserSessionSlackNotification
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    SlackService.new.session_booked(user, date, time, location)
    user_session.save!
  end
end
