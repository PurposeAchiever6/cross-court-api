module Subscriptions
  class PlaceSubscription
    include Interactor::Organizer

    around do |interactor|
      context.chargeable = context.product

      interactor.call
    end

    organize MakeDiscount,
             Subscriptions::CreateSubscription,
             Payments::Create,
             Subscriptions::UpdateUserSubscriptionCredits,
             PromoCodes::IncrementTimesUsed,
             PromoCodes::CreateUserPromoCode,
             Events::PurchasePlaced,
             Events::NewMember
  end
end
