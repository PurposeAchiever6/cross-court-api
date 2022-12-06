class AddRequiredToPlayerEvaluationFormSections < ActiveRecord::Migration[6.0]
  def change
    add_column :player_evaluation_form_sections, :required, :boolean, default: true
    add_index :player_evaluation_form_sections, :title, unique: true
  end
end
