# == Schema Information
#
# Table name: sec_exam_maps
#
#  id             :integer         not null, primary key
#  semester_id    :integer
#  section_id     :integer
#  exam_id        :integer
#  subject_id     :integer
#  scheduled_time :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

class SecExamMap < TenantManager
  belongs_to :section
  validates_presence_of :section
  belongs_to :exam
  validates_presence_of :exam
  
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_exam, lambda { |exam_id| where('exam_id = ? ', exam_id)}        	
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}        	
    	
end
