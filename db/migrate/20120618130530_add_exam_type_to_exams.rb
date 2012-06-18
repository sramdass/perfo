class AddExamTypeToExams < ActiveRecord::Migration
  def change
    add_column :exams, :exam_type, :integer, :default => 0
  end
end
