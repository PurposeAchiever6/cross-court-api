module Subscriptions
  class SendSubscriptionUpdatedSlackNotification
    include Interactor

    def call
      SlackService.new(context.user)
                  .subscription_updated(context.subscription, context.old_product)
    end
  end
end
