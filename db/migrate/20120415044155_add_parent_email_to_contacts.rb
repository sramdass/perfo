class AddParentEmailToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :parent_email, :string
  end
end
