class AddFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :work_occupation, :string
    add_column :users, :work_company, :string
    add_column :users, :work_industry, :string
    add_column :users, :links, :string, array: true, default: []
  end
end
