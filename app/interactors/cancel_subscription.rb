class CancelSubscription
  include Interactor::Organizer

  organize DeleteSubscription, ResetUserSubscriptionCredits, SendSubscriptionCanceledSlackNotification,
           SendSubscriptionCanceledEvent
end
