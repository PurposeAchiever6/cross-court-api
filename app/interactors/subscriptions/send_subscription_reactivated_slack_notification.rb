module Subscriptions
  class SendSubscriptionReactivatedSlackNotification
    include Interactor

    def call
      SlackService.new(context.user).subscription_reactivated(context.subscription)
    end
  end
end
