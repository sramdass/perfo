class AddImageToFaculites < ActiveRecord::Migration
  def change
    add_column :faculties, :image, :string
  end
end
