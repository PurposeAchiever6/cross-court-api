class AddLocationToSession < ActiveRecord::Migration[6.0]
  def change
    add_reference :sessions, :location, null: false, index: true
  end
end
