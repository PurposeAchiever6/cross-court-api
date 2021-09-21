class SubscriptionReactivation
  include Interactor::Organizer

  organize ReactivateSubscription, SendSubscriptionReactivatedSlackNotification
end
