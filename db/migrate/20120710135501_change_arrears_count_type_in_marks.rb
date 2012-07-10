class ChangeArrearsCountTypeInMarks < ActiveRecord::Migration
  def change
  	remove_column :marks, :arrears_count
  	add_column :marks, :arrears_count, :integer
  end
end
