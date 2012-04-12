# == Schema Information
#
# Table name: institutions
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  type               :string(255)
#  address            :text
#  registered_address :text
#  ceo                :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  subdomain          :string(255)
#  tenant_id          :integer
#

class Institution < TenantManager
end
