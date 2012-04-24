# == Schema Information
#
# Table name: sec_sub_maps
#
#  id          :integer         not null, primary key
#  semester_id :integer
#  section_id  :integer
#  subject_id  :integer
#  faculty_id  :integer
#  mark_column :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class SecSubMap < TenantManager
  belongs_to :section
  validates_presence_of :section
  belongs_to :subject
  validates_presence_of :subject
  
  # no dependent destroy. When the faculty is removed we still want to know which subject goes to which section	
  belongs_to :faculty	
  # If we give this we will always get "Faculty cannot be blank validation error." During the update and create the section along with its
  #sec_sub_maps and sec_exam_maps are saved before we parse the parameters and update the faculty_ids.
  #validates_presence_of :faculty
  
  scope :for_section, lambda { |section_id| where('section_id = ? ', section_id)}           
  scope :for_subject, lambda { |subject_id| where('subject_id = ? ', subject_id)}        	
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
  
end
