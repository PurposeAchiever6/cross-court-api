class AddNoShowUpFeeChargedToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :no_show_up_fee_charged, :boolean, default: false
  end
end
