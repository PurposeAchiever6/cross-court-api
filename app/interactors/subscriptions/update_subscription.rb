module Subscriptions
  class UpdateSubscription
    include Interactor::Organizer

    organize Subscriptions::ChangeSubscription,
             CreatePurchase,
             Subscriptions::UpdateUserSubscriptionCredits,
             PromoCodes::IncrementTimesUsed,
             PromoCodes::CreateUserPromoCode,
             Subscriptions::SendSubscriptionUpdatedSlackNotification,
             Events::PurchasePlaced
  end
end
