class DropTableGoals < ActiveRecord::Migration[7.0]
  def change
    drop_table :goals

    PaperTrail::Version.where(item_type: "Goal").destroy_all
  end
end
