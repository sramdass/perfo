# == Schema Information
#
# Table name: blood_groups
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class BloodGroup < TenantManager
	
  validates_presence_of			:name
  validates_length_of					:name, 							:maximum => 15	
  
  validates_length_of					:description,						:maximum => 50

end
