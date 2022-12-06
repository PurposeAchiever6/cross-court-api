class CreatePlayerEvaluations < ActiveRecord::Migration[6.0]
  def change
    create_table :player_evaluations do |t|
      t.belongs_to :user
      t.json :evaluation, default: {}
      t.float :total_score
      t.date :date
      t.timestamps
    end
  end
end
