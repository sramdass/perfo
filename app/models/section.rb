# == Schema Information
#
# Table name: sections
#
#  id            :integer         not null, primary key
#  department_id :integer
#  batch_id      :integer
#  name          :string(255)
#  short_name    :string(255)
#  code          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Section < TenantManager
  belongs_to :batch
  validates_presence_of :batch
  validates_associated :batch  
  
  belongs_to :department  	  
  validates_presence_of :department
  validates_associated :department
  
  has_many :students, :dependent => :destroy
  
  has_many :sec_sub_maps, :dependent => true, :dependent => :destroy
  has_many :subjects, :through => :sec_sub_maps
  
  has_many :sec_exam_maps, :dependent => true, :dependent => :destroy
  has_many :exams, :through => :sec_exam_maps  
  
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5
  
  def semester_subjects
    SecSubMap.for_semester(@semester_id).for_section(@section.id).all
  end  	
end
