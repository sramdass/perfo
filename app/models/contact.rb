# == Schema Information
#
# Table name: contacts
#
#  id              :integer         not null, primary key
#  user_type       :string(255)
#  user_id         :integer
#  address         :text
#  pin             :string(255)
#  email           :string(255)
#  mobile          :string(255)
#  home_phone      :string(255)
#  emergency_phone :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  parent_mobile   :string(255)
#  parent_email    :string(255)
#

class Contact < TenantManager
  belongs_to :user,		 				:polymorphic => true
  
  validates_length_of					:address, 							:maximum => 200
  
  validates_length_of					:pin,		 							:maximum => 10
  
  validates_presence_of			:email
  validates_uniqueness_of			:email
  validates_length_of					:email,								:maximum => 100
  validates										:email,  								:email_format => true  
  
  validates_presence_of			:mobile
  validates_length_of					:mobile, 							:maximum => 15
  
  validates_length_of					:home_phone, 				:maximum => 30
  
  validates_length_of					:emergency_phone, 		:maximum => 15    
  
  validates_presence_of 			:parent_mobile,				:if => :this_is_a_student?
  validates_length_of					:parent_mobile, 				:maximum => 30
    																								 
  validates_presence_of			:parent_email,					:if => :this_is_a_student?
  validates_uniqueness_of			:parent_email
  validates_length_of					:parent_email,					:maximum => 100
  validates										:parent_email,  				:email_format => true,
  																									:if => :this_is_a_student?
   																								 
  
  def this_is_a_student?
    user_type == "Student"
  end
      
end
