class CancelSubscriptionAtPeriodEnd
  include Interactor::Organizer

  organize DeleteSubscriptionAtPeriodEnd, SendSubscriptionCanceledSlackNotification,
           SendSubscriptionCanceledEvent
end
