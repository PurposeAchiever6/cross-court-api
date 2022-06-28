class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount,
           Users::Charge,
           IncrementUserCredits,
           PromoCodes::IncrementTimesUsed,
           PromoCodes::CreateUserPromoCode,
           SetDropInExpirationDate,
           Events::PurchasePlaced
end
