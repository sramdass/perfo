class AddParentMobileToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :parent_mobile, :string
  end
end
