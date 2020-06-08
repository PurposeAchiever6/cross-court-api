class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount, ChargeCard, CreatePurchase, IncrementUserCredits, SendPurchasePlacedEvent,
           CreateUserPromoCode
end
