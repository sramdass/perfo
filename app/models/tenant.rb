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
  
  validate										:cannot_change_subdomain
     
  
  #Use the following to change the humanization of attributes. For Example, if you need to change
  #the email to Email-address.
  #HUMANIZED_ATTRIBUTES = {  }
  #def self.human_attribute_name(attr)
    #HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  #end                   
  before_save :check_activation_and_send_email  
  before_save :prepare_tenant
  before_destroy :remove_tenant_schema
  
  
  def activate_tenant
  	if self.activated?
      self.activation_token = random_string
    end
  end
  
  def send_email(todo)
    PerfoMailer.activate_tenant(self, todo).deliver  	
  end
  
  def create_profile(admin_login, password, password_conf)
    orig_search_path = TenantManager.connection.schema_search_path
    TenantManager.connection.schema_search_path = self.subdomain
  	begin
      contact = Contact.new(:email => self.email, :mobile => self.phone)    
      faculty = Faculty.new(:name => admin_login, :id_no =>admin_login, :female => false, :contact => contact)
      role = Role.find_by_name!('Administrator')
      profile = UserProfile.create!(:login => faculty.id_no, :password => password, :password_confirmation => password_conf, :user => faculty, :roles => [role])
      TenantManager.connection.schema_search_path = orig_search_path
      return true
    rescue
      faculty = Faculty.find_by_name(admin_login)
      faculty.destroy if faculty
      TenantManager.connection.schema_search_path = orig_search_path
      return false
    end
  end  
  
  def clear_profile
    orig_search_path = TenantManager.connection.schema_search_path
  	TenantManager.connection.schema_search_path = self.subdomain  	
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
  
  def check_activation_and_send_email  
  	if self.activated? #Activated check box is checked off
  	  #create a activation token if there is not one
      self.activation_token = random_string if !self.activation_token
  	  if self.new_record? #for a new record, create a new activation token and send email.
  	    self.send_email("activate")
  	  else #for  old record
  	  	#if the old activated value is false do the following. If the old value is true, 
  	    #we do not need to do anything, as there is not change in the activated value
  	    if !self.activated_was 
  	      #If the control has reached here, and if the subdomain is nil, it means that the tenant has already
  	      #been created and activated, but the tenant has not gone through the activation part to create 
  	      #the subdomain and admin. And then the tenant has been deactivated for some reason.
  	      #Deactivation would have created a new token, so we need to send the activation email with the
  	      #new activation token.
  	      if !self.subdomain 
  	        self.send_email("activate")
  	        return
  	      end
  	      #if the subdomain value is there, it means that the client has been activated previously, and
  	      #been deactivated by the administrator. We do not need to go through the activation part again.
  	      #Just let them know, they can use the application again.
  	      self.send_email("reactivate")
  	    end
  	  end

  	else #Activated box is NOT checked off
  		
      #for a new record, it has just been created, we do not inform anything to the tenant.
      return if self.new_record?
      #send a deactivate email, if the tenant was already activated, but now deactivated.
      self.send_email("deactivate") if self.activated_was
      #Genarate a new activation token, so that the client will not be able to activate himself
      #with the previous token
      self.activation_token = random_string
  	end
  	
  end
  
  def random_string
    #Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{Time.now.to_f}"))[0..7]
    SecureRandom.base64
  end  
  
  def cannot_change_subdomain
    if subdomain && subdomain_was && subdomain != subdomain_was
      errors.add(:subdomain, "cannot be changed now")
    end
  end
  
end
