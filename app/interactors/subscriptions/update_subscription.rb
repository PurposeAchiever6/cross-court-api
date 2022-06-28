module Subscriptions
  class UpdateSubscription
    include Interactor::Organizer

    organize Subscriptions::ChangeSubscription,
             Subscriptions::UpdateUserSubscriptionCredits,
             PromoCodes::IncrementTimesUsed,
             PromoCodes::CreateUserPromoCode,
             Subscriptions::SendSubscriptionUpdatedSlackNotification
  end
end
