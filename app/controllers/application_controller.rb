class ApplicationController < ActionController::Base
  require 'pgtools'
  require 'exceptions'

  helper_method :current_tenant, :current_profile, :current_ability, :admin?
  protect_from_forgery

  before_filter :load_tenant_and_validate_profile
  before_filter :mailer_set_url_options  
  
  #Provide the exceptions handler here.
  #rescue_from ActiveRecord::RecordNotFound, :with => :rescue_not_found  
  rescue_from Exceptions::InvalidTenant, :with => :rescue_invalid_tenant
  
  rescue_from CanCan::AccessDenied do |exception|
   if current_profile
     redirect_to dashboard_path, :alert => "You are not allowed to access that page"
   #Use this here: - request.env['HTTP_REFERER'] || root_url
   else
     redirect_to login_path, :alert => "Please log in/sign up before accessing the application"
   end
  end  
    
  def load_tenant_and_validate_profile
  	if request.subdomain == ""
  	  TenantManager.connection.schema_search_path = "public"
  	elsif
  	  @current_tenant = Tenant.find_by_subdomain(request.subdomain) #Uses ActiveRecord::Base's connection.
  	  #@current_tenant = Tenant.find_by_subdomain("abc")   	
      raise Exceptions::InvalidTenant  if !@current_tenant
      #For every request, we just check the schema path and update if it is not correct.
      if TenantManager.connection.schema_search_path != @current_tenant.subdomain
        TenantManager.connection.schema_search_path = @current_tenant.subdomain
      end
    end
  end
  
  def mailer_set_url_options
    #ActionMailer::Base.default_url_options[:host] = "#{request.subdomain}.lvh.me:3000"
    if request.subdomain == ""
      ActionMailer::Base.default_url_options[:host] = "#{request.host_with_port}"
    else
      ActionMailer::Base.default_url_options[:host] = "#{request.subdomain}.#{request.host_with_port}"
    end
  end    
  
  def first_run?
  	@current_tenant.nil?
  end
  def invalid_tenant?
  	@current_tenanat.subdomain != request.subdomain
  end
  
 def admin?
   request.subdomain.blank?
 end
 
 def current_tenant
 	tenant = @current_tenant || Tenant.find_by_subdomain(request.subdomain)
    if current_profile && tenant && current_profile.tenant_id != tenant.id
      return nil
    end
    return tenant
 end
 
  def current_profile
  #Destroying  a cookie using code just empties the cookie. So just checking for nil is not sufficient.
    if cookies[:auth_token] && !(cookies[:auth_token].empty?)
      begin
      @current_profile ||= UserProfile.find_by_auth_token!(cookies[:auth_token])
      rescue ActiveRecord::RecordNotFound
      redirect_to login_path
      end
    else
      nil
    end
  end   
  
  #This will return the ability of the current_profile
  def current_ability
    @current_ability ||= Ability.new(current_profile)
  end
  
  protected
  def rescue_not_found
    respond_to do |type|
      type.html { render :file => "#{Rails.root}/public/500.html", :status => "500 Error" }
      type.all  { render :nothing => true, :status => "500 Error" }
    end
  end  	  
  
  def rescue_invalid_tenant
    render :file => "#{Rails.root}/public/invalid_tenant.html", :status => "500 Error" 
  end
  
  #def local_request?
  #  false
  #end
  #
  #def rescue_action_in_public(exception)
  #  case exception
  #  when ActiveRecord::RecordNotFound
  #    render :file => "#{Rails.root}/public/404.html", :status => 404
  #  else
  #    super
  #  end
  #end
  
  
  
end
