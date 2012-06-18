class AddExamTypeToSecExamMaps < ActiveRecord::Migration
  def change
    add_column :sec_exam_maps, :exam_type, :integer, :default => 0
  end
end
