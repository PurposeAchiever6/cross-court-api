class AddPromoCodeToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscriptions, :promo_code
  end
end
