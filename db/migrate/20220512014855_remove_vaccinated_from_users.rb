class RemoveVaccinatedFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :vaccinated, :boolean
  end
end
