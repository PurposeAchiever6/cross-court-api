class AddIsOpenClubToSession < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :is_open_club, :boolean, default: false
  end
end
