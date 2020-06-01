class CanceledUserSession
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    if user_session.in_cancellation_time?
      user.increment(:credits)
      user.save!
      user_session.credit_reimbursed = true
      SlackService.new(user, date, time, location).session_canceled_in_time
      KlaviyoService.new.event(Event::SESSION_CANCELED_IN_TIME, user)
    else
      SlackService.new(user, date, time, location).session_canceled_out_of_time
      KlaviyoService.new.event(Event::SESSION_CANCELED_OUT_OF_TIME, user)
    end
    user_session.state = :canceled
    user_session.save!
  end
end
