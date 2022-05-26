class AddAllSkillLevelsToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :all_skill_levels_allowed, :boolean, default: true
  end
end
