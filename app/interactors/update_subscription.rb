class UpdateSubscription
  include Interactor::Organizer

  organize ChangeSubscription,
           CreatePurchase,
           UpdateUserSubscriptionCredits,
           IncrementTimesUsedPromoCode,
           CreateUserPromoCode,
           SendPurchasePlacedEvent
end
