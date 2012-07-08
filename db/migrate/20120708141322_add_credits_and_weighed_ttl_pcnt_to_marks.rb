class AddCreditsAndWeighedTtlPcntToMarks < ActiveRecord::Migration
  def change
    add_column :marks, :total_credits, :integer
    add_column :marks, :weighed_total_percentage, :float
  end
end
