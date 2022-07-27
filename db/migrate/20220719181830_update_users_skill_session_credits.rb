class UpdateUsersSkillSessionCredits < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :skill_session_credits, :subscription_skill_session_credits
  end
end
