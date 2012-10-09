class AddFinalsToExams < ActiveRecord::Migration
  def change
    add_column :exams, :finals, :boolean
  end
end
