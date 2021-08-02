class CanceledUserSession
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    in_cancellation_time = user_session.in_cancellation_time?
    is_free_session = user_session.is_free_session
    session_date = user_session.date.strftime(Session::DAY_MONTH_NAME_FORMAT)

    if in_cancellation_time || is_free_session
      user.increment(:credits)
      user.free_session_state = :claimed if is_free_session
      user.save!

      user_session.credit_reimbursed = true
    end

    if in_cancellation_time
      SlackService.new(user, date, time, location).session_canceled_in_time
      KlaviyoService.new.event(
        Event::SESSION_CANCELED_IN_TIME,
        user,
        user_session: user_session,
        extra_params: {
          session_date: session_date,
          cancellation_period: Session::CANCELLATION_PERIOD
        }
      )
    else
      result = ChargeCanceledOutOfTimeUserSession.call(user_session: user_session)

      if result.failure?
        SlackService.new(user, date, time, location)
                    .session_canceled_out_of_time_with_charge_error(result.message)
      else
        SlackService.new(user, date, time, location).session_canceled_out_of_time
      end

      KlaviyoService.new.event(
        Event::SESSION_CANCELED_OUT_OF_TIME,
        user,
        user_session: user_session,
        extra_params: {
          session_date: session_date,
          cancellation_period: Session::CANCELLATION_PERIOD,
          amount_charged: result.amount_charged,
          unlimited_credits: user.unlimited_credits?
        }
      )
    end

    user_session.state = :canceled
    user_session.save!
  end
end
