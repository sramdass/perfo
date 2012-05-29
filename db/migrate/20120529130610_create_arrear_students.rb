class CreateArrearStudents < ActiveRecord::Migration
  def change
    create_table :arrear_students do |t|
      t.integer :section_id
      t.integer :semester_id
      t.integer :subject_id
      t.integer :student_id

      t.timestamps
    end
  end
end
