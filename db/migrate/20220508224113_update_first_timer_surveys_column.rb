class UpdateFirstTimerSurveysColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :first_timer_surveys, :how_do_you_hear_about_us, :string
    add_column :first_timer_surveys, :how_did_you_hear_about_us, :string
  end
end
