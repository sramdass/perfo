class Resource < ActiveRecord::Base
  has_many :resource_actions, :dependent => :destroy
  accepts_nested_attributes_for :resource_actions, :reject_if => :has_only_destroy?, :allow_destroy => true  
  
  has_many :permissions, :dependent => :destroy
  
  validates 	:name, 	:presence => true, 
               					    :length => {:maximum => 50}  
               					    
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
