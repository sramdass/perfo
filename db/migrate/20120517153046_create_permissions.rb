class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :role_id
      t.integer :resource_id
      t.integer :privilege
      t.integer :constraints

      t.timestamps
    end
  end
end
