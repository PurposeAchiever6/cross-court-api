class CreateSessionSurvey < ActiveRecord::Migration[7.0]
  def change
    create_table :session_surveys do |t|
      t.integer :rate
      t.text :feedback

      t.references :user
      t.references :user_session

      t.timestamps
    end
  end
end
