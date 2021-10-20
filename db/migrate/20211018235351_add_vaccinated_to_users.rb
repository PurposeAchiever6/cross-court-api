class AddVaccinatedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :vaccinated, :boolean, default: false
  end
end
