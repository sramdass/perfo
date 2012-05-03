# == Schema Information
#
# Table name: faculties
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  id_no          :string(255)
#  female         :boolean
#  qualification  :string(255)
#  designation_id :integer
#  blood_group_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  start_date     :date
#  end_date       :date
#

class Faculty < TenantManager
  has_one :contact, :as => :user, :dependent => :destroy	
  accepts_nested_attributes_for :contact
  validates_presence_of 		:contact
  validates_associated 			:contact
  
  #No dependent destroy
  has_many :sec_sub_maps  
  
  belongs_to :blood_group
  validates_associated :blood_group
  
  belongs_to :designation
  validates_associated :designation
  
  has_many :hods, :dependent => true, :dependent => :destroy
  has_many :departments, :through => :hods  
  
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 50
  
  validates_presence_of			:id_no
  validates_length_of					:id_no,								:maximum => 20
  
  validates_inclusion_of				:female,								:in => [true, false]
  
  validates_length_of					:qualification,					:maximum => 20,
  																									:allow_nil => true
  validate 										:start_date_and_end_date	  
  
  def start_date_and_end_date
  	if start_date && end_date && start_date > end_date
  	  errors.add(:start_date, "should not be later than Ends at")
  	  errors.add(:end_date, "should not be earlier than Starts from")
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
