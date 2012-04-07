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
  validates_presence_of			:name
  validates_length_of					:name, 								:maximum => 30

  validates_length_of					:subdomain,						:maximum => 30,
  																									:allow_nil => true
  validates_uniqueness_of			:subdomain                     																			
  
  validates_inclusion_of				:locked, :activated,			 :in => [true, false]
  
  validates_presence_of			:email
  validates_uniqueness_of			:email
  validates_length_of					:email,								:maximum => 100
  validates										:email,  								:email_format => true  
  																								
  validates_length_of					:phone,								:maximum => 20																						
     
  
  #Use the following to change the humanization of attributes. For Example, if you need to change
  #the email to Email-address.
                    																			
  #HUMANIZED_ATTRIBUTES = {  }
  #def self.human_attribute_name(attr)
    #HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  #end                       																			
end
