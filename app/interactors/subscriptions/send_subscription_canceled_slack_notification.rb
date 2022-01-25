module Subscriptions
  class SendSubscriptionCanceledSlackNotification
    include Interactor

    def call
      SlackService.new(context.user).subscription_canceled(context.subscription)
    end
  end
end
