class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.string :name
      t.string :type
      t.text :address
      t.text :registered_address
      t.string :ceo

      t.timestamps
    end
  end
end
