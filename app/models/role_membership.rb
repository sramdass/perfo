class RoleMembership < TenantManager
  belongs_to :role
  belongs_to :user_profile	
  
  scope :for_role, lambda { |role_id| where('role_id = ? ', role_id)}             					      
  scope :for_user_profile, lambda { |profile_id| where('user_profile_id = ? ', profile_id)}             		
end
