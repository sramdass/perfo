# == Schema Information
#
# Table name: tenants
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  subdomain         :string(255)
#  email             :string(255)
#  phone             :string(255)
#  subscription_from :date
#  subscription_to   :date
#  activation_token  :string(255)
#  activated         :boolean
#  locked            :boolean
#  schema_username   :string(255)
#  schema_password   :string(255)
#  students_count    :integer
#  faculties_count   :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class Tenant < ActiveRecord::Base
	
  attr_accessor :admin_login, :password	
  attr_accessible :admin_login, :password, :password_confirmation, :name, :subdomain, :locked, :activated, :email, :phone, :subscription_from,  :subscription_to
	
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30

  validates_length_of					:subdomain,						:maximum => 30,
  																									:allow_nil => true #skips the validation if the value is nil
  validates_uniqueness_of			:subdomain                   																			
  
  validates_inclusion_of				:locked, :activated,			 :in => [true, false]
  
  validates_presence_of			:email
  validates_uniqueness_of			:email
  validates_length_of					:email,								:maximum => 100
  validates										:email,  								:email_format => true  
  																								
  validates_presence_of			:phone
  validates_uniqueness_of			:phone
  validates_length_of					:phone,								:maximum => 100
     
  
  #Use the following to change the humanization of attributes. For Example, if you need to change
  #the email to Email-address.
  #HUMANIZED_ATTRIBUTES = {  }
  #def self.human_attribute_name(attr)
    #HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  #end                   
  before_save :prepare_tenant
  before_destroy :remove_tenant_schema
  
  
  def activate_tenant
  	if self.activated?
      self.activation_token = random_string
    end
  end
  
  def send_activation_email
    PerfoMailer.activate_tenant(self).deliver  	
  end
  
  def create_profile(admin_login, password)
  	orig_search_path = TenantManager.connection.schema_search_path
  	TenantManager.connection.schema_search_path = self.subdomain
    contact = Contact.create!(:email => self.email, :mobile => self.phone)    
    faculty = Faculty.new(:name => admin_login, :id_no =>admin_login, :female => false, :contact => contact)
    profile = UserProfile.create!(:login => faculty.id_no, :password => password, :password_confirmation => password, :user => faculty)
    role = Role.find_by_name!('Administrator')
    rm = RoleMembership.create!(:user_profile_id => profile.id, :role_id => role.id)
    TenantManager.connection.schema_search_path = orig_search_path
  end  
  
    
 private
  def prepare_tenant
  	if subdomain && !subdomain_was
  	  @schema = subdomain
      create_schema
      load_tables
    end
  end

  def create_schema
  	PgTools.create_schema @schema
  end
  
  def load_tables
    return if Rails.env.test?
    PgTools.set_search_path @schema
    load "#{Rails.root}/db/schema.rb"
    PgTools.restore_default_search_path
  end  
  
  #create_tenant and grant_permissions are not used now. Heroku does not allow new
  #users to be created in the shared database. Keeping the code, incase I earn sufficient
  #money to own a dedicated database.
  def create_tenant
  	#password = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{userid}"))[0..7]
  	PgTools.create_tenant(userid, db_password)
  end

  def grant_permissions
  	PgTools.grant_permissions(userid, @schema)
  end
  
  def remove_tenant_schema
  	@schema = subdomain
    PgTools.delete_schema @schema
  end

  
  def random_string
    #Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{Time.now.to_f}"))[0..7]
    SecureRandom.base64
  end  
  
end
