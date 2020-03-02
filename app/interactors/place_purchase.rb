class PlacePurchase
  include Interactor::Organizer

  organize ChargeCard, CreatePurchase, IncrementUserCredits, SendPurchasePlacedEvent
end
