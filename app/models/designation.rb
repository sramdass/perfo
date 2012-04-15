# == Schema Information
#
# Table name: designations
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Designation < TenantManager
  validates_presence_of			:name
  validates_length_of					:name, 							:maximum => 20
  
  validates_length_of					:name, 							:maximum => 50
    
end
