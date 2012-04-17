class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.string :id_no
      t.boolean :female
      t.string :father_name
      t.date :start_date
      t.date :end_date
      t.integer :blood_group_id
      t.integer :degree_finished

      t.timestamps
    end
  end
end
