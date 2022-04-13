class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount,
           Users::Charge,
           CreatePurchase,
           IncrementUserCredits,
           PromoCodes::IncrementTimesUsed,
           PromoCodes::CreateUserPromoCode,
           SetDropInExpirationDate,
           Events::PurchasePlaced
end
