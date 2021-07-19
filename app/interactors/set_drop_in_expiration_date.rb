class SetDropInExpirationDate
  include Interactor

  def call
    user = context.user
    user.drop_in_expiration_date = Time.zone.today + User::DROP_IN_EXPIRATION_DAYS
    user.save!
  end
end
