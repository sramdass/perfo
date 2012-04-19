# == Schema Information
#
# Table name: school_types
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

class SchoolType < TenantManager
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_length_of					:description,						:maximum => 100
end
