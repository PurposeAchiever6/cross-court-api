class CreateFirstTimerSurveys < ActiveRecord::Migration[6.0]
  def change
    create_table :first_timer_surveys do |t|
      t.string :how_do_you_hear_about_us
      t.references :user
      t.timestamps
    end
  end
end
