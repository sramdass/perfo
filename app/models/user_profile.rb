# == Schema Information
#
# Table name: user_profiles
#
#  id                     :integer         not null, primary key
#  login                  :string(255)
#  password_hash          :string(255)
#  password_salt          :string(255)
#  password_reset_token   :string(255)
#  auth_token             :string(255)
#  password_reset_sent_at :datetime
#  user_type              :string(255)
#  user_id                :integer
#  last_login_at          :datetime
#  activated              :boolean
#  locked                 :boolean
#  failed_login_count     :integer
#  created_at             :datetime
#  updated_at             :datetime
#  tenant_id              :integer
#

class UserProfile < TenantManager
  belongs_to :user, :polymorphic => true
  validates_presence_of :user
  
  has_many :role_memberships, :dependent => true, :dependent => :destroy
  has_many :roles, :through => :role_memberships
  accepts_nested_attributes_for :roles, :reject_if => :has_only_destroy?, :allow_destroy => true  
  
  attr_accessor :password, :profile_type
  attr_accessible :login, :password, :password_confirmation, :profile_type, :user, :role_ids, :locked, :activated, :roles
  before_save :encrypt_password
  before_create { generate_token(:auth_token) }
  before_validation :set_default_values, :on => :create

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_length_of :password, :minimum => 3, :maximum => 50, :on => :create
  validates_presence_of :login
  validates_uniqueness_of :login
  validates :failed_login_count, :numericality => true, :length => { :minimum => 0 }
  validates_inclusion_of				:locked,								:in => [true, false]
  
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
  
  #We need to define the roles, as the default roles do not work. Read he above.
  def roles
    my_roles = Array.new
    self.role_memberships.each do |mem|
      my_roles << mem.role
    end
    return my_roles
  end
  
  def login
    self.user.id_no if self.user #Condition needed. Note that the user is nil for the new ser profile
  end
  
  def authenticate(password)	
    if self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)
      self
    else
      nil
    end
  end

  def encrypt_password
   if password.present?
     self.password_salt = BCrypt::Engine.generate_salt
     self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
   end
  end	

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    PerfoMailer.password_reset(self).deliver
  end
  
  def generate_token(column)
    begin
      self[column] = SecureRandom.base64
    end while UserProfile.exists?(column => self[column])
  end  	
  
  def update_failed_login_count(login_success)
  	if login_success == true
  	   self.failed_login_count = 0
    else
      self.failed_login_count = self.failed_login_count + 1;
    end
    #Make sure the locking an unlocking happens here
  end
  
  def activated?
  	self.activated
  end
  
  def locked?
  	self.locked
  end  
  
  def valid_profile?
   self.activated? && !self.locked?
  end
  
  private
  
  def set_default_values
    self.failed_login_count ||= 0
    self.locked ||= false
    self.activated ||= true
  end
  
  def has_only_destroy?(attrs)
    attrs.each do |k,v|
      if k !="_destroy" && !v.blank?
        return false
      end
    end
    return true	
  end	  
    
end
