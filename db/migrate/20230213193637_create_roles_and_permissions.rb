class CreateRolesAndPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end

    add_index :roles, :name, unique: true

    create_table :admin_user_roles do |t|
      t.references :role, null: false
      t.references :admin_user, null: false

      t.timestamps
    end

    add_index :admin_user_roles, [:role_id, :admin_user_id], unique: true

    create_table :permissions do |t|
      t.string :name, unique: true

      t.timestamps
    end

    create_table :role_permissions do |t|
      t.references :role, null: false
      t.references :permission, null: false

      t.timestamps
    end

    add_index :role_permissions, [:role_id, :permission_id], unique: true
  end
end
