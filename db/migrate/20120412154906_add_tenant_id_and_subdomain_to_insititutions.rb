class AddTenantIdAndSubdomainToInsititutions < ActiveRecord::Migration
  def change
    add_column :institutions, :subdomain, :string
    add_column :institutions, :tenant_id, :integer
  end
end
