module Subscriptions
  class SubscriptionReactivation
    include Interactor::Organizer

    organize Subscriptions::ReactivateSubscription,
             Subscriptions::SendSubscriptionReactivatedSlackNotification
  end
end
