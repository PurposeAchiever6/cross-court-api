class CancelSubscription
  include Interactor::Organizer

  organize DeleteSubscription, ResetUserSubscriptionCredits
end
