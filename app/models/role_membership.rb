# == Schema Information
#
# Table name: role_memberships
#
#  id              :integer         not null, primary key
#  role_id         :integer
#  user_profile_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class RoleMembership < TenantManager
  belongs_to :role
  belongs_to :user_profile	
  
  scope :for_role, lambda { |role_id| where('role_id = ? ', role_id)}             					      
  scope :for_user_profile, lambda { |profile_id| where('user_profile_id = ? ', profile_id)}             		
end
