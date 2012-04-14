class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :institution_id
      t.string :name
      t.string :short_name
      t.string :code
      t.boolean :lab

      t.timestamps
    end
  end
end
