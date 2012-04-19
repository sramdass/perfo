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
  NOT_KNOWN = -1
  PASSED = 0
  FAILED = 1
  DROP_OUT = 2
  
 #Dont check fo the presence of the parent object in case of the nested attributes
  belongs_to :student
  
  belongs_to :school_type
  validates_associated :school_type
  validates_presence_of :school_type

  validates_length_of					:school_name,					:maximum => 30	
  
  validates_inclusion_of				:status,								:in => [NOT_KNOWN, PASSED, FAILED, DROP_OUT]  
  
  validates_numericality_of 		:percent_marks,				:greater_than_or_equal_to => 0,
   																									:less_than_or_equal_to => 100
end
