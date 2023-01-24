class CreateSessionAllowedProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :session_allowed_products do |t|
      t.belongs_to :session
      t.belongs_to :product
    end
  end
end
