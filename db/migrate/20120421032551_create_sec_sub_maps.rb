class CreateSecSubMaps < ActiveRecord::Migration
  def change
    create_table :sec_sub_maps do |t|
      t.integer :semester_id
      t.integer :section_id
      t.integer :subject_id
      t.integer :faculty_id
      t.string :mark_column

      t.timestamps
    end
  end
end
