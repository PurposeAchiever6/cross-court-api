class PlaceSubscription
  include Interactor::Organizer

  organize CreateSubscription,
           CreatePurchase,
           UpdateUserSubscriptionCredits,
           IncrementTimesUsedPromoCode,
           CreateUserPromoCode,
           SendPurchasePlacedEvent
end
