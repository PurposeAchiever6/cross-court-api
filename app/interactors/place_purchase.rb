class PlacePurchase
  include Interactor::Organizer

  organize MakeDiscount,
           Users::Charge,
           DropIns::IncrementUserCredits,
           PromoCodes::IncrementTimesUsed,
           PromoCodes::CreateUserPromoCode,
           DropIns::SetExpirationDate,
           DropIns::SendPurchaseSlackNotification,
           Events::PurchasePlaced
end
