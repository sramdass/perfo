class ApplicationController < ActionController::Base
  require 'pgtools'
  helper_method :current_tenant
  protect_from_forgery
  #This filter is skipped for Tenants Controller. Check tenants  controller
  #If this is not skipped, there will be an infinite redirect when we redirect
  #to invalid_tenant_url
  before_filter :load_tenant

private  

  def load_tenant
    #Modifications need to be done for verifying current_tenant so that the user does not switch identity in the middle
  	#@current_tenant = Tenant.find_by_subdomain(request.subdomain) #Uses ActiveRecord::Base's connection.
  	@current_tenant = Tenant.find_by_subdomain("abc") 
    if !@current_tenant
      redirect_to invalid_tenant_url
      return
    end
    #For every request, we just check the schema path and update if it is not correct.
    if TenantManager.connection.schema_search_path != @current_tenant.subdomain
      TenantManager.connection.schema_search_path = @current_tenant.subdomain
    end
  end
  
  def first_run?
  	@current_tenant.nil?
  end
  def invalid_tenant?
  	@current_tenanat.subdomain != request.subdomain
  end
  
  def non_admin?
  	!request.subdomain.blank?
 end
 
 def current_tenant
   @current_tenant || Tenant.find_by_subdomain(request.subdomain)
 #   if cookies[:auth_token] && !(cookies[:auth_token].empty?)
 #    @current_profile ||= UserProfile.find_by_auth_token!(cookies[:auth_token])
 #  else
 #    nil
 #  end
 end


end
