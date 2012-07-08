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
  
  has_many :assignments, :class_name => "Exam", :foreign_key => "examination_id"
  belongs_to :examination, :class_name => "Exam"  
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5	
  
  #We do not need an examination for all the assignments. If an examination is associated,
  #the assignments will be displayed along with the exam marks when the mark sheet is displayed.
  #If not examination is provided, those assignments will be considered independent ones.
  #validate										:needs_examination_only_for_assignments
  
  before_save :nullify_examination_for_non_assignments
  
  attr_accessor :rabl_name
  
  def nullify_examination_for_non_assignments
    if exam_type != EXAM_TYPE_ASSIGNMENT
      self.examination_id = nil
    end
  end
  
  def needs_examination_only_for_assignments
    if exam_type == EXAM_TYPE_ASSIGNMENT
      if !examination
        errors.add(:examination_id, "cannot be blank")
      end
      if examination && examination.exam_type == EXAM_TYPE_ASSIGNMENT
      	errors.add(:examination_id, "cannot be another assignment")
      end
    end
  end
  
  def rabl_name
    "#{self.name} "
  end  
end
