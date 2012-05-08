class AddImageToStudents < ActiveRecord::Migration
  def change
    add_column :students, :image, :string
  end
end
