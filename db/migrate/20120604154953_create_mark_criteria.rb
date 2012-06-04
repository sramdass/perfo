class CreateMarkCriteria < ActiveRecord::Migration
  def change
    create_table :mark_criteria do |t|
      t.integer :section_id
      t.integer :subject_id
      t.integer :semester_id
      t.integer :exam_id
      t.float :max_marks
      t.float :pass_marks

      t.timestamps
    end
  end
end
