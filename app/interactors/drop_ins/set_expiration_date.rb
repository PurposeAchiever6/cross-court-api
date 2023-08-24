module DropIns
  class SetExpirationDate
    include Interactor

    def call
      user = context.user
      product = context.product
      credits_expiration_days = product.credits_expiration_days

      return unless credits_expiration_days

      user.drop_in_expiration_date = Time.zone.today + credits_expiration_days.days
      user.save!
    end
  end
end
