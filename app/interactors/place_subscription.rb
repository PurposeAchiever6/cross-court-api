class PlaceSubscription
  include Interactor::Organizer

  organize CreateSubscription, CreatePurchase, UpdateUserSubscriptionCredits, SendPurchasePlacedEvent, CreateUserPromoCode
end
