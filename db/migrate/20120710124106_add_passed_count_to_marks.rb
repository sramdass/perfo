class AddPassedCountToMarks < ActiveRecord::Migration
  def change
    add_column :marks, :passed_count, :integer
  end
end
