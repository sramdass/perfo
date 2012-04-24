class CreateSecExamMaps < ActiveRecord::Migration
  def change
    create_table :sec_exam_maps do |t|
      t.integer :semester_id
      t.integer :section_id
      t.integer :exam_id
      t.integer :subject_id
      t.datetime :scheduled_time

      t.timestamps
    end
  end
end
