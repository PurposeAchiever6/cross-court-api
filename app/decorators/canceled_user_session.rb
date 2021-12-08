class CanceledUserSession
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    in_cancellation_time = user_session.in_cancellation_time?
    is_free_session = user_session.is_free_session
    user_id = user.id
    user_session_id = user_session.id

    if in_cancellation_time || is_free_session
      user.increment(:credits)
      user.free_session_state = :claimed if is_free_session
      user.save!

      user_session.credit_reimbursed = true
    end

    if in_cancellation_time
      SlackService.new(user, date, time, location).session_canceled_in_time

      CreateActiveCampaignDealJob.perform_now(
        ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_IN_TIME,
        user_id,
        user_session_id: user_session_id
      )
    else
      result = ChargeCanceledOutOfTimeUserSession.call(user_session: user_session)

      if result.failure?
        SlackService.new(user, date, time, location)
                    .session_canceled_out_of_time_with_charge_error(result.message)
      else
        SlackService.new(user, date, time, location).session_canceled_out_of_time
      end

      CreateActiveCampaignDealJob.perform_now(
        ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_OUT_OF_TIME,
        user_id,
        user_session_id: user_session_id,
        cancellation_period: Session::CANCELLATION_PERIOD.to_i / (60 * 60),
        amount_charged: result.amount_charged,
        unlimited_credits: user.unlimited_credits?.to_s
      )
    end

    user_session.state = :canceled
    user_session.save!
  end
end
