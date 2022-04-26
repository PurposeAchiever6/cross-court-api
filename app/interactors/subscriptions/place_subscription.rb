module Subscriptions
  class PlaceSubscription
    include Interactor::Organizer

    organize Subscriptions::CreateSubscription,
             CreatePurchase,
             Subscriptions::UpdateUserSubscriptionCredits,
             PromoCodes::IncrementTimesUsed,
             PromoCodes::CreateUserPromoCode,
             Events::PurchasePlaced,
             Events::NewMember
  end
end
