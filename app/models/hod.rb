# == Schema Information
#
# Table name: hods
#
#  id            :integer         not null, primary key
#  department_id :integer
#  faculty_id    :integer
#  semester_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Hod < TenantManager
  belongs_to :department
  validates_presence_of :department
  belongs_to :faculty
  validates_presence_of :faculty
 
  #We also have given a has_many relation from the semester model. When a semester is deleted, all the corresponding hod rows will be removed. 
  belongs_to :semester
  
  scope :for_department, lambda { |dept_id| where('department_id = ? ', dept_id)}           
  scope :for_faculty, lambda { |faculty_id| where('faculty_id = ? ', faculty_id)}        	
  scope :for_semester, lambda { |semester_id| where('semester_id = ? ', semester_id)}     
    
end
