# == Schema Information
#
# Table name: pre_college_marks
#
#  id             :integer         not null, primary key
#  school_type_id :integer
#  school_name    :string(255)
#  percent_marks  :float
#  status         :integer
#  student_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class PreCollegeMark < TenantManager
  belongs_to :student
  validates_associated :student  
  
  belongs_to :school_type
  validates_associated :school_type
end
