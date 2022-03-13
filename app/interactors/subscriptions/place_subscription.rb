module Subscriptions
  class PlaceSubscription
    include Interactor::Organizer

    organize Subscriptions::CreateSubscription,
             CreatePurchase,
             Subscriptions::UpdateUserSubscriptionCredits,
             IncrementTimesUsedPromoCode,
             CreateUserPromoCode,
             Events::PurchasePlaced,
             Events::NewMember
  end
end
