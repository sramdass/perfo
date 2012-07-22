class AddAssignmentColumnsToMarks < ActiveRecord::Migration
  def change
    add_column :marks, :weighed_total_percentage_ia, :float
    add_column :marks, :passed_count_ia, :integer
    add_column :marks, :arrears_count_ia, :integer
    add_column :marks, :weighed_pass_marks_percentage_ia, :float
  end
end
