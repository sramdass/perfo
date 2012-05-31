# == Schema Information
#
# Table name: exams
#
#  id             :integer         not null, primary key
#  institution_id :string(255)
#  name           :string(255)
#  short_name     :string(255)
#  code           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Exam < TenantManager
  belongs_to :institution  	
  validates_presence_of :institution
  
  has_many :marks, :dependent => :destroy
  
  has_many :sec_exam_maps, :dependent => true, :dependent => :destroy
  has_many :sections, :through => :sec_exam_maps      
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5	
  
  attr_accessor :rabl_name
  
  def rabl_name
    "#{self.name} "
  end  
end
