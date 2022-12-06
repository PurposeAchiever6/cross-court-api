class CreatePlayerEvaluationFormSectionOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :player_evaluation_form_section_options do |t|
      t.string :title
      t.string :content
      t.float :score
      t.belongs_to :player_evaluation_form_section,
                   index: { name: :index_on_player_evaluation_form_section_id }
      t.timestamps
    end
  end
end
