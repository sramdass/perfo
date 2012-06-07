# == Schema Information
#
# Table name: arrear_students
#
#  id          :integer         not null, primary key
#  section_id  :integer
#  semester_id :integer
#  subject_id  :integer
#  student_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class ArrearStudent < TenantManager
  belongs_to :section
  validates_associated :section
  belongs_to :semester
  validates_associated :semester
  belongs_to :subject
  validates_associated :subject
  belongs_to :student
  validates_associated :student
  
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_subject, lambda { |subject_id| where('subject_id = ? ', subject_id)}        	
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
  scope :for_student, lambda { |student_id| where('student_id = ? ', student_id)}     
    
end
