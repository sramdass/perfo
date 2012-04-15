class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :user_type
      t.integer :user_id
      t.text :address
      t.string :pin
      t.string :email
      t.string :mobile
      t.string :home_phone
      t.string :emergency_phone

      t.timestamps
    end
  end
end
