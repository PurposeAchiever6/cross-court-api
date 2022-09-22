module UserSessions
  class Cancel
    include Interactor

    def call
      user_session = context.user_session
      from_session_canceled = context.from_session_canceled

      user = user_session.user
      is_free_session = user_session.is_free_session
      in_cancellation_time = user_session.in_cancellation_time?

      if from_session_canceled || in_cancellation_time || is_free_session
        increment_user_credit(user, user_session.credit_used_type)
        user.free_session_state = :claimed if is_free_session
        user.save!

        user_session.credit_reimbursed = true
      end

      user_session.state = :canceled
      user_session.save!

      if from_session_canceled
        cancel_session_actions(user_session)
      else
        if in_cancellation_time
          cancel_in_time_actions(user_session)
        else
          cancel_out_of_time_actions(user_session)
        end

        Sessions::ReachUserOnWaitlistJob.perform_later(user_session.session.id, user_session.date)
      end
    end

    private

    def cancel_session_actions(user_session)
      user = user_session.user
      location = user_session.location
      session_time = user_session.time

      SlackService.new(
        user,
        user_session.date,
        session_time,
        location
      ).session_canceled

      SonarService.send_message(
        user,
        I18n.t(
          'notifier.sonar.session_canceled',
          name: user.first_name,
          when: user_session.date_when_format,
          time: session_time.strftime(Session::TIME_FORMAT),
          location: "#{location.name} (#{location.address})",
          schedule_url: "#{ENV['FRONTENT_URL']}/locations"
        )
      )
    end

    def cancel_in_time_actions(user_session)
      user = user_session.user

      SlackService.new(
        user,
        user_session.date,
        user_session.time,
        user_session.location
      ).session_canceled_in_time

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_IN_TIME,
        user.id,
        user_session_id: user_session.id
      )
    end

    def cancel_out_of_time_actions(user_session)
      user = user_session.user

      amount_charged = UserSessions::ChargeCanceledOutOfTime.call(
        user_session: user_session
      ).amount_charged

      SlackService.new(
        user,
        user_session.date,
        user_session.time,
        user_session.location
      ).session_canceled_out_of_time

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_OUT_OF_TIME,
        user.id,
        user_session_id: user_session.id,
        amount_charged: amount_charged,
        unlimited_credits: user.unlimited_credits?.to_s
      )
    end

    def increment_user_credit(user, credit_used_type)
      case credit_used_type&.to_sym
      when :subscription_credits
        user.increment(:subscription_credits) unless user.unlimited_credits?
      when :subscription_skill_session_credits
        unless user.unlimited_skill_session_credits?
          user.increment(:subscription_skill_session_credits)
        end
      else
        user.increment(:credits)
      end
    end
  end
end
