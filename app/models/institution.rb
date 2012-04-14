# == Schema Information
#
# Table name: institutions
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  tipe               :string(255)
#  address            :text
#  registered_address :text
#  ceo                :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  subdomain          :string(255)
#  tenant_id          :integer
#

class Institution < TenantManager
  																									
  has_many :semesters  	
  has_many :departments
  has_many :subjects
  has_many :exams
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:tipe
  validates_length_of					:tipe,	 								:maximum => 30	
  
  validates_presence_of			:ceo
  validates_length_of					:ceo,	 								:maximum => 30	  
  
  validates_presence_of			:address
  validates_length_of					:address, 							:maximum => 150
  
  validates_presence_of			:registered_address
  validates_length_of					:registered_address, 		:maximum => 30
  
  validates_presence_of			:tenant_id  #We cannot have a belongs_to association here. We are in a different schema
  
  validates_length_of					:subdomain,						:maximum => 30,
  																									:allow_nil => true #skips the validation if the value is nil
																									
    
end
