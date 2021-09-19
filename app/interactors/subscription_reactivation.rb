class SubscriptionReactivation
  include Interactor::Organizer

  organize ReactiveSubscription, SendSubscriptionReactivatedSlackNotification
end
