class CreateBloodGroups < ActiveRecord::Migration
  def change
    create_table :blood_groups do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
