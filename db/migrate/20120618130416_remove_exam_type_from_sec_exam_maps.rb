class RemoveExamTypeFromSecExamMaps < ActiveRecord::Migration
  def up
    remove_column :sec_exam_maps, :exam_type
  end

  def down
  end
end
