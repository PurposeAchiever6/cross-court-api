# This migration creates the `versions` table used by paper-trail gem.
class CreateVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :versions do |t|
      t.string   :item_type, null: false
      t.bigint   :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.json     :object
      t.datetime :created_at
    end

    add_index :versions, %i[item_type item_id]
  end
end
