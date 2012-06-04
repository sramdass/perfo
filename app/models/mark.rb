class Mark < TenantManager
  belongs_to :section
  validates_presence_of :section
  validates_associated :section

  belongs_to :student
  validates_presence_of :student
  validates_associated :student
  
  belongs_to :semester
  validates_presence_of :semester
  validates_associated :semester
  
  belongs_to :exam
  validates_presence_of :semester
  validates_associated :semester
  
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
  scope :for_student, lambda { |student_id| where('student_id = ? ', student_id)}     
  scope :for_exam, lambda { |exam_id| where('exam_id = ? ', exam_id)}               
  

end
