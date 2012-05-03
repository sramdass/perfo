# == Schema Information
#
# Table name: departments
#
#  id             :integer         not null, primary key
#  institution_id :string(255)
#  name           :string(255)
#  short_name     :string(255)
#  code           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Department < TenantManager
  belongs_to :institution
  validates_presence_of :institution
  
  has_many :sections
  
  has_many :hods, :dependent => true, :dependent => :destroy
  has_many :faculties, :through => :hods
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5	
end
