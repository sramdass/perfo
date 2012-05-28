# == Schema Information
#
# Table name: resource_actions
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :text
#  code        :integer
#  resource_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class ResourceAction < ActiveRecord::Base
  belongs_to :resource
  
  validates 	:name, 	:presence => true, 
               					    :length => {:maximum => 50}    
               					    
  validates 	:code,	 	:presence => true, 
  									:numericality => {:less_than => 32, :greater_than => 0}
               					    
  validates 	:description, :length => {:maximum => 300}  
  
  #TODO: This is not working as desired. Rectify this problem.               					    		           					    
  #validate :code_should_not_repeat_in_a_resource     
  
  def code_should_not_repeat_in_a_resource
  	already_existing = ResourceAction.where('resource_id = ? and code = ?', self.resource_id, self.code).all
  	if !already_existing.empty?
  	  errors.add(:code, "should be unique for each actions.")
  	end
  end
      	
end
