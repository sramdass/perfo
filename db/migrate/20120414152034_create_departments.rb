class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :institution_id
      t.string :name
      t.string :short_name
      t.string :code

      t.timestamps
    end
  end
end
