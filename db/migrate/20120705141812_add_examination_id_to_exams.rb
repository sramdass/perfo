class AddExaminationIdToExams < ActiveRecord::Migration
  def change
    add_column :exams, :examination_id, :integer
  end
end
