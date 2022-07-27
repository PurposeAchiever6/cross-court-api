class AddSkillSessionCreditsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :skill_session_credits, :integer, default: 0
  end
end
