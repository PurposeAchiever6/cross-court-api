module DropIns
  class SetExpirationDate
    include Interactor

    def call
      user = context.user
      product = context.product

      return if product.season_pass

      user.drop_in_expiration_date = Time.zone.today + User::DROP_IN_EXPIRATION_DAYS
      user.save!
    end
  end
end
