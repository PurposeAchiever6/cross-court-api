module Subscriptions
  class PauseSubscription
    include Interactor

    def call
      subscription = context.subscription
      subscription_id = subscription.id
      months = context.months.to_i

      raise SubscriptionIsNotActiveException unless subscription.active?

      raise SubscriptionInvalidPauseMonthsException unless [1, 2].include?(months)

      raise MaximumNumberOfPausesReachedException unless subscription.can_pause?

      wait_until = subscription.current_period_end - 1.day
      resumes_at = wait_until + months.months

      ::Subscriptions::PauseJob.set(
        wait_until: wait_until
      ).perform_later(
        subscription_id,
        resumes_at.to_i
      )

      SubscriptionPause.create!(
        paused_from: wait_until,
        paused_until: resumes_at,
        subscription_id: subscription_id
      )
    end
  end
end
