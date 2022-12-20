class AddChargeableToPayments < ActiveRecord::Migration[6.0]
  def change
    add_reference :payments, :chargeable, polymorphic: true, index: true
  end
end
