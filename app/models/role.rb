#Important Note:-
#Role is a sub class of Active record base class. But the role memberships, useprofiles
#and permissions are derived from Tenant Manager. The idea is that any role is created
#only once in the admin schema(public) and will be used by all the Tenant Managers.
#Each of the tenants will have its own role_memberships and permissions.
#Role.find(:id).role_memberships will yield -> the role memberships for the current Tenant
#Manager.
#Role.find(:id).user_profiles will yield -> the user profiles for the current Tenant
#Manager.
#UserProfile.find(:id).roles will yield a empty result. I am assuming that the user_profile is trying
#to find the roles in its own schema path and gets 0 results.
#However, UserProfile.find(:id).role_memberships and RoleMembership.find(:id).role are yielding
#the right results.
#So, if we need the roles for a user profile use, 
          # @user_profile.role_memberships.each do |role_mem| 
		  #    role_mem.role.name
	      #  end
class Role < ActiveRecord::Base
  has_many :permissions, :dependent => :destroy
  
  has_many :role_memberships, :dependent => true, :dependent => :destroy
  has_many :user_profiles, :through => :role_memberships  
  
  validates 	:name, 	:presence => true, 
               						:length => {:maximum => 30},
               						:uniqueness => true	
               						
  validates 	:description, 			:length => {:maximum => 300}
  
  def has_privilege?(resource_id, action_code)
  	result = 0
  	privilege_in_db = self.permissions.find_by_resource_id(resource_id).try(:privilege)
  	result = (privilege_in_db & 2**action_code) if privilege_in_db
  	if result !=0
  	  return true
  	else
  	  return false
  	end	
  end
  
  #This method is generic for all the actions for a particular resource.
  #This will check if this role can perform 'action_name' on the resource 'resource_name'
  #Ex: if this role can 'write' on the resource 'Faculty'
  def can_perform?(action_name, resource_name)
  	res_id = Resouce.find_by_name(resource_nam.camelize)
    action_code = ResourceAction.find_by_name("#{action_name.upcase}_ALL_RECORDS").code
  	has_privilege(res_id, action_code)
  end  
  
  def can_read?(resource_name)
  	can_perform?("read", resource_name)
  end
  
  def can_create?(resource_name)
  	can_perform?("create", resource_name)
  end
  
  def can_update?(resource_name)
  	can_perform?("edit", resource_name)
  end
  
    def can_delete?(resource_name)
  	can_perform?("delete", resource_name)
  end    

end
