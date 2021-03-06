# == Schema Information
#
# Table name: mark_criteria
#
#  id          :integer         not null, primary key
#  section_id  :integer
#  subject_id  :integer
#  semester_id :integer
#  exam_id     :integer
#  max_marks   :float
#  pass_marks  :float
#  created_at  :datetime
#  updated_at  :datetime
#

class MarkCriteria < TenantManager
  belongs_to :section
  validates_presence_of :section
  validates_associated :section

  belongs_to :exam
  validates_presence_of :exam
  validates_associated :exam
  
  belongs_to :semester
  validates_presence_of :semester
  validates_associated :semester
  
  belongs_to :exam
  validates_presence_of :semester
  validates_associated :semester  
  
  validates_numericality_of :max_marks, :less_than_or_equal_to => MAX_ALLOWED_MARKS, :greater_than_or_equal_to => MIN_ALLOWED_MARKS
  validates_numericality_of :pass_marks, :less_than_or_equal_to => MAX_ALLOWED_MARKS, :greater_than_or_equal_to => MIN_ALLOWED_MARKS
  
  #validates_numericality_of :max_marks, :greater_than_or_equal_to => 0, :allow_nil => true, :message => "too small"
  #validates_numericality_of :pass_marks, :greater_than_or_equal_to => 0, :allow_nil => true, :message => "too small"  
  
  	
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
  scope :for_subject, lambda { |subject_id| where('subject_id = ? ', subject_id)}     
  scope :for_exam, lambda { |exam_id| where('exam_id = ? ', exam_id)}       	
  
  
  def self.default_max_marks
  	return DEFAULT_MAX_MARKS
  end
  
  def self.default_pass_marks(max_marks)
  	max_marks * MarkCriteria.default_pass_marks_percentage.to_f / 100
  end
  
  def self.default_pass_marks_percentage
  	return DEFAULT_PASS_MARKS_PERCENTAGE
  end
  
    
end
