class AddPaymentMethodToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscriptions, :payment_method
  end
end
