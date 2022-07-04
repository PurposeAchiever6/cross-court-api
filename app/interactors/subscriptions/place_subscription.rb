module Subscriptions
  class PlaceSubscription
    include Interactor::Organizer

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
