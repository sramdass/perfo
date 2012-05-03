class CreateHods < ActiveRecord::Migration
  def change
    create_table :hods do |t|
      t.integer :department_id
      t.integer :faculty_id
      t.integer :semester_id

      t.timestamps
    end
  end
end
