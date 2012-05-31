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
  has_many :arrear_students, :dependent => :destroy
  
  has_many :marks, :dependent => :destroy
  accepts_nested_attributes_for :marks, :reject_if => :has_only_destroy?, :allow_destroy => true
  
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
  
  #rabl_name is the virtual attribute. Every model requires the attribute value to be 
  #formatted differently when it is sent to the client during an ajax request, and this
  #attribute is used for that formatting.
  #This will be of most useful when we have to send an object that belongs to two
  #different model. For example, section belongs to batch and department. When
  #we have to send the section names for a particular batch, we can format the 
  #section name as 'Mechanical Engineering - section - A'
  #For more information refer common.js and views/selectors/entity.json.rabl  
  attr_accessor :rabl_name
  
  def semester_subjects
    SecSubMap.for_semester(@semester_id).for_section(@section.id).all
  end  	
  
  def rabl_name
    "#{self.department.name} - #{self.name}"
  end
  
  def has_only_destroy?(attrs)
    attrs.each do |k,v|
      if k !="_destroy" && !v.blank?
        return false
      end
    end
    return true	
  end	  
    
end
