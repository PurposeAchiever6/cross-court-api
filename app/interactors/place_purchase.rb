class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount,
           ChargeCard,
           CreatePurchase,
           IncrementUserCredits,
           PromoCodes::IncrementTimesUsed,
           PromoCodes::CreateUserPromoCode,
           SetDropInExpirationDate,
           Events::PurchasePlaced
end
