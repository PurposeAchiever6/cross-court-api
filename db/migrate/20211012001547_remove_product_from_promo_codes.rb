class RemoveProductFromPromoCodes < ActiveRecord::Migration[6.0]
  def change
    remove_reference :promo_codes, :product
  end
end
