class CreateMarks < ActiveRecord::Migration
  def change
    create_table :marks do |t|
      t.integer :student_id
      t.integer :semester_id
      t.integer :section_id
      t.integer :exam_id
      t.float :sub1
      t.float :sub2
      t.float :sub3
      t.float :sub4
      t.float :sub5
      t.float :sub6
      t.float :sub7
      t.float :sub8
      t.float :sub9
      t.float :sub10
      t.float :sub11
      t.float :sub12
      t.float :sub13
      t.float :sub14
      t.float :sub15
      t.float :sub16
      t.float :sub17
      t.float :sub18
      t.float :sub19
      t.float :sub20
      t.float :total
      t.string :grade
      t.string :arrears_count
      t.text :comments

      t.timestamps
    end
  end
end
