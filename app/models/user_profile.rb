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
#

class UserProfile < TenantManager
  belongs_to :user, :polymorphic => true
  validates_presence_of :user
  
  attr_accessor :password, :profile_type
  attr_accessible :login, :password, :password_confirmation, :profile_type, :user
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
end
