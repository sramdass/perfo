class CreateGrades < ActiveRecord::Migration
  def change
    create_table :grades do |t|
      t.string :name
      t.string :color_code
      t.float :cut_off_percentage
      t.text :description

      t.timestamps
    end
  end
end
