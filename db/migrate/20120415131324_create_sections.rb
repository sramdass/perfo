class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.integer :department_id
      t.integer :batch_id
      t.string :name
      t.string :short_name
      t.string :code

      t.timestamps
    end
  end
end
