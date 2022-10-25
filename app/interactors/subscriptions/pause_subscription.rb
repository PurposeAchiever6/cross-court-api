module Subscriptions
  class PauseSubscription
    include Interactor

    def call
      subscription = context.subscription
      subscription_id = subscription.id
      months = context.months.to_i
      reason = context.reason

      raise SubscriptionIsNotActiveException unless subscription.active?
      raise SubscriptionInvalidPauseMonthsException unless [1, 2].include?(months)
      raise MaximumNumberOfPausesReachedException unless subscription.can_pause?

      wait_until = subscription.current_period_end - 1.day
      resumes_at = wait_until + months.months

      subscription_pause = SubscriptionPause.create!(
        paused_from: wait_until,
        paused_until: resumes_at,
        subscription_id: subscription_id,
        reason: reason
      )

      SlackService.new(subscription.user)
                  .subscription_paused_for_next_period(subscription,
                                                       months: months,
                                                       reason: reason,
                                                       pause_start_on_datetime: wait_until)

      job_id = ::Subscriptions::PauseJob.set(
        wait_until: wait_until
      ).perform_later(
        subscription_id,
        resumes_at.to_i,
        subscription_pause.id
      ).provider_job_id

      subscription_pause.update!(job_id: job_id)
    end
  end
end
