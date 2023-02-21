module UserSessions
  class Cancel
    include Interactor

    def call
      user_session = context.user_session
      from_session_canceled = context.from_session_canceled
      canceled_with_open_club = context.canceled_with_open_club

      user = user_session.user
      is_free_session = user_session.is_free_session
      in_cancellation_time = user_session.in_cancellation_time?
      session = user_session.session
      shooting_machine_reservations = user_session.shooting_machine_reservations

      user_session.state = :canceled
      user_session.save!

      user_session.session_guests.each do |session_guest|
        SessionGuests::Remove.call(user_session:, session_guest_id: session_guest.id)
      end

      if shooting_machine_reservations.present?
        ShootingMachineReservations::Cancel.call(
          shooting_machine_reservations:
        )
      end

      return if session.is_open_club?

      if from_session_canceled || in_cancellation_time || is_free_session
        # On free session we reimburse user credits because we charge them a fee
        increment_user_credit(user, session, user_session)
        user.free_session_state = :claimed if is_free_session
        user.save!

        user_session.credit_reimbursed = true
        user_session.save!
      end

      if from_session_canceled
        cancel_session_actions(user_session, canceled_with_open_club)
      else
        if in_cancellation_time
          cancel_in_time_actions(user_session)
        else
          cancel_out_of_time_actions(user_session)
        end

        Sessions::ReachUserOnWaitlistJob.perform_later(session.id, user_session.date)
      end
    end

    private

    def cancel_session_actions(user_session, canceled_with_open_club)
      user = user_session.user
      location = user_session.location
      session_time = user_session.time

      SlackService.new(
        user,
        user_session.date,
        session_time,
        location
      ).session_canceled

      sms_text_identifier = if canceled_with_open_club
                              'notifier.sonar.session_canceled_with_open_club'
                            else
                              'notifier.sonar.session_canceled'
                            end

      SonarService.send_message(
        user,
        I18n.t(
          sms_text_identifier,
          name: user.first_name,
          when: user_session.date_when_format,
          time: session_time.strftime(Session::TIME_FORMAT),
          location: "#{location.name} (#{location.address})",
          schedule_url: "#{ENV.fetch('FRONTENT_URL', nil)}/locations"
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
        user_session:
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
        amount_charged:,
        unlimited_credits: user.unlimited_credits?.to_s
      )
    end

    def increment_user_credit(user, session, user_session)
      session_cost_credits = session.cost_credits
      credit_used_type = user_session.credit_used_type
      scouting = user_session.scouting

      user.increment(:scouting_credits) if scouting

      case credit_used_type&.to_sym
      when :subscription_credits
        user.increment(:subscription_credits, session_cost_credits) unless user.unlimited_credits?
      when :subscription_skill_session_credits
        unless user.unlimited_skill_session_credits?
          user.increment(:subscription_skill_session_credits, session_cost_credits)
        end
      when :credits_without_expiration
        user.increment(:credits_without_expiration, session_cost_credits)
      else
        user.increment(:credits, session_cost_credits)
      end
    end
  end
end
