class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.integer :institution_id
      t.string :name
      t.string :short_name
      t.string :code
      t.date :start_date
      t.date :end_date
      t.boolean :current_semester

      t.timestamps
    end
  end
end
