# == Schema Information
#
# Table name: subjects
#
#  id             :integer         not null, primary key
#  institution_id :string(255)
#  name           :string(255)
#  short_name     :string(255)
#  code           :string(255)
#  lab            :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

class Subject < TenantManager
  belongs_to :institution  	
  validates_presence_of :institution
  
  has_many :sec_sub_maps, :dependent => true, :dependent => :destroy
  has_many :sections, :through => :sec_sub_maps    
  
  has_many :arrear_students, :dependent => :destroy  
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5	
  
  validates 										:lab, 					:inclusion => { :in => [true, false] }
end
