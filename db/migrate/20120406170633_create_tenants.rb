class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :subdomain
      t.string :email
      t.string :phone
      t.date :subscription_from
      t.date :subscription_to
      t.string :activation_token
      t.boolean :activated
      t.boolean :locked
      t.string :schema_username
      t.string :schema_password
      t.integer :students_count
      t.integer :faculties_count

      t.timestamps
    end
  end
end
