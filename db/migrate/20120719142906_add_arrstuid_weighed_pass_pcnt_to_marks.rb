class AddArrstuidWeighedPassPcntToMarks < ActiveRecord::Migration
  def change
    add_column :marks, :arrear_student_id, :integer
    add_column :marks, :weighed_pass_marks_percentage, :float
  end
end
