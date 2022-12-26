module Subscriptions
  class CancelSubscription
    include Interactor::Organizer

    organize Subscriptions::DeleteSubscription,
             Subscriptions::ResetUserSubscriptionCredits,
             Subscriptions::SendSubscriptionCanceledEvent
  end
end
