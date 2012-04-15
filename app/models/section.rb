class Section < TenantManager
  belongs_to :batch
  validates_presence_of :batch
  
  belongs_to :department  	  
  validates_presence_of :department
  
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30	
  
  validates_presence_of			:short_name
  validates_length_of					:short_name,					:maximum => 8
  
  validates_presence_of			:code
  validates_length_of					:code,	 								:maximum => 5
end