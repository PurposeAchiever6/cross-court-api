class PlacePurchase
  include Interactor::Organizer

  around do |interactor|
    context.chargeable = context.product

    interactor.call
  end

  organize MakeDiscount,
           Users::Charge,
           DropIns::IncrementUserCredits,
           PromoCodes::IncrementTimesUsed,
           PromoCodes::CreateUserPromoCode,
           DropIns::SetExpirationDate,
           DropIns::SendPurchaseSlackNotification,
           Events::PurchasePlaced
end
