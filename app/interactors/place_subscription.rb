class PlaceSubscription
  include Interactor::Organizer

  organize CreateSubscription, CreatePurchase, UpdateUserSubscriptionCredits, SendPurchasePlacedEvent
end
