module Subscriptions
  class CancelSubscriptionAtPeriodEnd
    include Interactor::Organizer

    organize Subscriptions::DeleteSubscriptionAtPeriodEnd,
             Subscriptions::SendSubscriptionCanceledSlackNotification,
             Subscriptions::SendSubscriptionCanceledEvent
  end
end
