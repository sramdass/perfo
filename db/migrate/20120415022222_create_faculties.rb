class CreateFaculties < ActiveRecord::Migration
  def change
    create_table :faculties do |t|
      t.string :name
      t.string :id_no
      t.boolean :female
      t.string :qualification
      t.string :start_date
      t.string :end_date
      t.integer :designation_id
      t.integer :blood_group_id

      t.timestamps
    end
  end
end
