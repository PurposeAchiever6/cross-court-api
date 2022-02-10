class ChangeSessionExceptionsDateToDateType < ActiveRecord::Migration[6.0]
  def up
    change_column :session_exceptions, :date, :date
  end

  def down
    change_column :session_exceptions, :date, :datetime
  end
end
