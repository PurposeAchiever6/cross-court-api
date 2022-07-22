module Subscriptions
  class UpdateSubscription
    include Interactor::Organizer

    # Payment is created by stripe webhook
    organize Subscriptions::ChangeSubscription,
             Subscriptions::UpdateUserSubscriptionCredits,
             PromoCodes::IncrementTimesUsed,
             PromoCodes::CreateUserPromoCode,
             Subscriptions::SendSubscriptionUpdatedSlackNotification
  end
end
