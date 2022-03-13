class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount,
           ChargeCard,
           CreatePurchase,
           IncrementUserCredits,
           IncrementTimesUsedPromoCode,
           CreateUserPromoCode,
           SetDropInExpirationDate,
           Events::PurchasePlaced
end
