class CreatePlayerEvaluationFormSections < ActiveRecord::Migration[6.0]
  def change
    create_table :player_evaluation_form_sections do |t|
      t.string :title
      t.string :subtitle
      t.integer :order
      t.timestamps
    end
  end
end
