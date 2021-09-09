class CreateSkillLevel < ActiveRecord::Migration[6.0]
  def change
    create_table :skill_levels do |t|
      t.decimal :min, precision: 2, scale: 1
      t.decimal :max, precision: 2, scale: 1
      t.string :name
      t.string :description
    end

    add_reference :sessions, :skill_level, index: true
    remove_column :sessions, :level, :integer

    SkillLevel.create!(name: 'Beginner', min: 1, max: 2)
    SkillLevel.create!(name: 'Intermediate', min: 2.5, max: 5)
    SkillLevel.create!(name: 'Advanced', min: 5.5, max: 7)

    Session.update_all(skill_level_id: 1)
  end
end
