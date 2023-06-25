module UserSessions
  class ConsumeCredit
    include Interactor

    def call
      user_session = context.user_session
      not_charge_user_credit = context.not_charge_user_credit

      user = user_session.user
      session = user_session.session
      date = user_session.date

      session_allow_free_booking = session.allow_free_booking?(date, user)
      session_no_credit_required = session.cost_credits.zero?

      free_session = not_charge_user_credit \
                     || session_allow_free_booking \
                     || session_no_credit_required

      unless user_has_credits?(user, session, free_session)
        raise NotEnoughCreditsException, I18n.t('api.errors.user_sessions.not_enough_credits')
      end

      if user.free_session_claimed?
        user_session.first_session = true
        user_session.is_free_session = true
        user_session.free_session_payment_intent = user.free_session_payment_intent
        user.free_session_state = :used
      elsif user.user_sessions.reserved_or_confirmed.count == 1
        user_session.first_session = true
      end

      if free_session
        if not_charge_user_credit
          user_session.credit_used_type = :not_charge_user_credit
        elsif session_allow_free_booking
          user_session.credit_used_type = :allow_free_booking
        elsif session_no_credit_required
          user_session.credit_used_type = :no_credit_required
        end
      elsif session.skill_session?
        decrement_user_skill_session_credit(user, session, user_session)
      else
        decrement_user_session_credit(user, session, user_session)
      end

      first_time_subscription_credits_used_sms(user)

      user.save!
      user_session.save!
    end

    private

    def user_has_credits?(user, session, free_session)
      return true if free_session

      session_cost_credits = session.cost_credits

      return user.skill_session_credits?(session_cost_credits) if session.skill_session?

      user.credits?(session_cost_credits)
    end

    def decrement_user_skill_session_credit(user, session, user_session)
      session_cost_credits = session.cost_credits
      user_unlimited_skill_session_credits = user.unlimited_skill_session_credits?
      user_skill_credits = user.subscription_skill_session_credits >= session_cost_credits \
                           || user_unlimited_skill_session_credits

      if user_skill_credits
        unless user_unlimited_skill_session_credits
          user.decrement(:subscription_skill_session_credits, session_cost_credits)
        end
        user_session.credit_used_type = :subscription_skill_session_credits
      else
        decrement_user_session_credit(user, session, user_session)
      end
    end

    def decrement_user_session_credit(user, session, user_session)
      session_cost_credits = session.cost_credits

      if user.credits >= session_cost_credits
        user.decrement(:credits, session_cost_credits)
        user_session.credit_used_type = :credits
      elsif user.credits_without_expiration >= session_cost_credits
        user.decrement(:credits_without_expiration, session_cost_credits)
        user_session.credit_used_type = :credits_without_expiration
      else
        user.decrement(:subscription_credits, session_cost_credits) unless user.unlimited_credits?
        user_session.credit_used_type = :subscription_credits
      end
    end

    def first_time_subscription_credits_used_sms(user)
      if user.active_subscription \
        && user.subscription_credits.zero? \
          && !user.first_time_subscription_credits_used_at?

        SonarService.send_message(
          user,
          I18n.t(
            'notifier.sonar.first_time_subscription_credits_used',
            name: user.first_name,
            link: "#{ENV.fetch('FRONTENT_URL', nil)}/memberships"
          )
        )

        user.first_time_subscription_credits_used_at = Time.zone.now
      end
    end
  end
end
