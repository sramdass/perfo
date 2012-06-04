class MarkCriteria < TenantManager
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
  scope :for_subject, lambda { |subject_id| where('subject_id = ? ', subject_id)}     
  scope :for_exam, lambda { |exam_id| where('exam_id = ? ', exam_id)}       	
end
