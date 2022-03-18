module Subscriptions
  class UpdateSubscription
    include Interactor::Organizer

    organize Subscriptions::ChangeSubscription,
             CreatePurchase,
             Subscriptions::UpdateUserSubscriptionCredits,
             IncrementTimesUsedPromoCode,
             CreateUserPromoCode,
             Events::PurchasePlaced
  end
end
