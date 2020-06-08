class UserSessionSlackNotification
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    SlackService.new(user, date, time, location).session_booked
    user_session.save!
  end
end
