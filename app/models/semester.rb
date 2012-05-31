# == Schema Information
#
# Table name: semesters
#
#  id               :integer         not null, primary key
#  institution_id   :integer
#  name             :string(255)
#  short_name       :string(255)
#  code             :string(255)
#  start_date       :date
#  end_date         :date
#  current_semester :boolean
#  created_at       :datetime
#  updated_at       :datetime
#

class Semester < TenantManager
  belongs_to :institution  	
  validates_presence_of :institution
  
  #When this semester is destroyed, all the hods for this semester should be removed.
  has_many :hods,  :dependent => true, :dependent => :destroy
  
  has_many :arrear_students, :dependent => :destroy  
  has_many :marks, :dependent => :destroy  
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5
  
  validates_presence_of			:start_date
  validates_presence_of			:end_date
  
  validate 										:start_date_and_end_date
  
  def start_date_and_end_date
  	if start_date > end_date
  	  errors.add(:start_date, "should not be later than Ends at")
  	  errors.add(:end_date, "should not be earlier than Starts from")
  	end
  end  
end
