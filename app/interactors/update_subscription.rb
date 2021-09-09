class UpdateSubscription
  include Interactor::Organizer

  organize ChangeSubscription, CreatePurchase, UpdateUserSubscriptionCredits, SendPurchasePlacedEvent, CreateUserPromoCode
end
