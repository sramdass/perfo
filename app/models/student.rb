# == Schema Information
#
# Table name: students
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  id_no           :string(255)
#  female          :boolean
#  father_name     :string(255)
#  start_date      :date
#  end_date        :date
#  blood_group_id  :integer
#  degree_finished :integer
#  created_at      :datetime
#  updated_at      :datetime
#  section_id      :integer
#  image           :string(255)
#

class Student < TenantManager
  NOT_KNOWN = -1
  DEGREE_COMPLETED = 0
  DEGREE_NOT_COMPLETED = 1
  DROP_OUT = 2
  
  #For the image upload
  mount_uploader :image, ImageUploader	  
  
  has_one :contact, :as => :user, :dependent => :destroy	
  accepts_nested_attributes_for :contact
  validates_presence_of 		:contact
  
  has_many :pre_college_marks, :dependent => :destroy
  accepts_nested_attributes_for :pre_college_marks, :reject_if => :has_only_destroy?, :allow_destroy => true
  
  has_many :arrear_students, :dependent => :destroy
  has_many :marks, :dependent => :destroy  
  
  belongs_to :blood_group
  validates_associated :blood_group
  
  belongs_to :section
  validates_associated :section
  validates_presence_of :section
  
  has_one :user_profile, :as => :user, :dependent => :destroy  

  #Since we are not using f.association in the student_fields, we need to validate th presence
  #exclusively for the * mark (required field) in the form
  validates_presence_of			:section_id
 
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 50
  
  validates_presence_of			:id_no
  validates_uniqueness_of			:id_no
  validates_length_of					:id_no,								:maximum => 20
  
  validates_length_of					:father_name,					:maximum => 50  
  
  validates_inclusion_of				:female,								:in => [true, false]
  
  validates_inclusion_of				:degree_finished,			:in => [NOT_KNOWN, DEGREE_COMPLETED, 
  																												DEGREE_NOT_COMPLETED, DROP_OUT]    
  
  validate 										:start_date_and_end_date	
  #Make sure that a student a faculty do not share the same id_no. id_no is used for the login in user profile.
  validate										:id_no_should_not_match_faculty_id_no  
  validate										:id_no_should_not_have_spaces  
  
  attr_accessor :rabl_name
  
  def rabl_name
    "#{self.name} (#{self.id_no}), #{self.section.name}, #{self.section.department.name}"
  end  
  
  def start_date_and_end_date
  	if start_date && end_date && start_date > end_date
  	  errors.add(:start_date, "should not be later than Ends at")
  	  errors.add(:end_date, "should not be earlier than Starts from")
  	end
  end    
  
  def id_no_should_not_match_faculty_id_no
    if id_no
      if Faculty.find_by_id_no(id_no)
      	errors.add(:id_no, "is already taken by a Faculty")
      end
    end
  end
  
  def id_no_should_not_have_spaces
  	if id_no
      unless id_no =~ /^[a-z0-9]+[-a-z0-9]*[a-z0-9]+$/i
        errors.add(:id_no, "only alphanumerics are allowed")
      end      
    end
  end  
  
#Returns true if there is only "_destroy" attribute available for nested models.
  def has_only_destroy?(attrs)
    attrs.each do |k,v|
      if k !="_destroy" && !v.blank?
        return false
      end
    end
    return true	
  end	  
end
