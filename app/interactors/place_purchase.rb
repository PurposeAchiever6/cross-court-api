class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount,
           ChargeCard,
           CreatePurchase,
           IncrementUserCredits,
           IncrementTimesUsedPromoCode,
           CreateUserPromoCode,
           SetDropInExpirationDate,
           SendPurchasePlacedEvent
end
