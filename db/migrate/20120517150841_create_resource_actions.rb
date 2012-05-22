class CreateResourceActions < ActiveRecord::Migration
  def change
    create_table :resource_actions do |t|
      t.string :name
      t.text :description
      t.integer :code
      t.integer :resource_id

      t.timestamps
    end
  end
end
