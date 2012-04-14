class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.string :institution_id
      t.string :name
      t.string :short_name
      t.string :code

      t.timestamps
    end
  end
end
