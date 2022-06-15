module Subscriptions
  class CancelSubscriptionPause
    include Interactor

    def call
      subscription = context.subscription
      subscription_pause = subscription.upcoming_subscription_pause

      Sidekiq::ScheduledSet.new.find_job(subscription_pause.job_id).delete

      subscription_pause.update!(
        status: :canceled,
        canceled_at: Time.zone.now
      )

      SlackService.new(subscription.user).subscription_pause_canceled(subscription)
    end
  end
end
