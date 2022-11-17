module UserSessions
  class ConsumeCredit
    include Interactor

    def call
      user_session = context.user_session
      not_charge_user_credit = context.not_charge_user_credit

      user = user_session.user
      session = user_session.session

      unless user_has_credits?(user, session, not_charge_user_credit)
        raise NotEnoughCreditsException, I18n.t('api.errors.user_session.not_enough_credits')
      end

      if user.free_session_claimed?
        user_session.first_session = true
        user_session.is_free_session = true
        user_session.free_session_payment_intent = user.free_session_payment_intent
        user.free_session_state = :used
      elsif user.user_sessions.not_canceled.count == 1
        user_session.first_session = true
      end

      unless not_charge_user_credit
        if session.skill_session?
          decrement_user_skill_session_credit(user, user_session)
        else
          decrement_user_session_credit(user, user_session)
        end
      end

      first_time_subscription_credits_used_sms(user)

      user.save!
      user_session.save!
    end

    private

    def user_has_credits?(user, session, not_charge_user_credit)
      return true if not_charge_user_credit

      return user.skill_session_credits? if session.skill_session?

      user.credits?
    end

    def decrement_user_skill_session_credit(user, user_session)
      if user.subscription_skill_session_credits.zero?
        if user.subscription_credits.zero?
          user.decrement(:credits)
          user_session.credit_used_type = :credits
        else
          user.decrement(:subscription_credits) unless user.unlimited_credits?
          user_session.credit_used_type = :subscription_credits
        end
      else
        unless user.unlimited_skill_session_credits?
          user.decrement(:subscription_skill_session_credits)
        end
        user_session.credit_used_type = :subscription_skill_session_credits
      end
    end

    def decrement_user_session_credit(user, user_session)
      if user.credits.positive?
        user.decrement(:credits)
        user_session.credit_used_type = :credits
      elsif user.credits_without_expiration.positive?
        user.decrement(:credits_without_expiration)
        user_session.credit_used_type = :credits_without_expiration
      else
        user.decrement(:subscription_credits) unless user.unlimited_credits?
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
            link: "#{ENV['FRONTENT_URL']}/memberships"
          )
        )

        user.first_time_subscription_credits_used_at = Time.zone.now
      end
    end
  end
end
