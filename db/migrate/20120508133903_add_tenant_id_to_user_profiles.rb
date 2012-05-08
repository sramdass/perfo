class AddTenantIdToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :tenant_id, :integer
  end
end
