class CreatePreCollegeMarks < ActiveRecord::Migration
  def change
    create_table :pre_college_marks do |t|
      t.integer :school_type_id
      t.string :school_name
      t.float :percent_marks
      t.integer :status
      t.integer :student_id

      t.timestamps
    end
  end
end
