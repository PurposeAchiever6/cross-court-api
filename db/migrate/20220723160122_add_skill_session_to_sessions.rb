class AddSkillSessionToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :skill_session, :boolean, default: false
  end
end
