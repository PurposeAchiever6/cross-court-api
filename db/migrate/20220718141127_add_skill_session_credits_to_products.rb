class AddSkillSessionCreditsToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :skill_session_credits, :integer, default: 0
  end
end
