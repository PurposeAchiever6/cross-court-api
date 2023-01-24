class SplitNameIntoFirstAndLast < ActiveRecord::Migration[6.0]
  def up
    change_table :users, bulk: true do |t|
      t.string :first_name, null: false, default: ''
      t.string :last_name, null: false, default: ''
    end

    User.find_each do |user|
      splitted_full_name = user.name.split
      user.first_name = splitted_full_name[0]
      user.last_name = splitted_full_name.drop(1).join(' ')
      user.save!
    end

    remove_column :users, :name
  end

  def down
    change_table :users, bulk: true do |t|
      t.string :name, null: false, default: ''
    end

    User.find_each do |user|
      user.update!(name: "#{user.first_name} #{user.last_name}")
    end

    change_table :users, bulk: true do |t|
      t.remove :first_name
      t.remove :last_name
    end
  end
end
