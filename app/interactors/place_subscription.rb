class PlaceSubscription
  include Interactor::Organizer

  organize CreateSubscription, CreatePurchase, IncrementUserSubscriptionCredits, SendPurchasePlacedEvent, CreateUserPromoCode
end
