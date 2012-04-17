# == Schema Information
#
# Table name: sections
#
#  id            :integer         not null, primary key
#  department_id :integer
#  batch_id      :integer
#  name          :string(255)
#  short_name    :string(255)
#  code          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Section < TenantManager
  belongs_to :batch
  validates_presence_of :batch
  validates_associated :batch  
  
  belongs_to :department  	  
  validates_presence_of :department
  validates_associated :department
  
  has_many :students
  validates_associated :students
  
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5
end
