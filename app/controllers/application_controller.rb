class ApplicationController < ActionController::Base
  require 'pgtools'
  helper_method :current_tenant
  protect_from_forgery
  before_filter :load_tenant

private  

  def load_tenant
  	if non_admin?
 	  #debugger
  	  @current_tenant = Tenant.find_by_subdomain(request.subdomain) #Uses ActiveRecord::Base's connection.
  	  if ENV['DATABASE_URL']
	  	db_config = URI.parse(ENV['DATABASE_URL'])
  		TenantManager.establish_connection(
		    :adapter  => db_config.scheme == 'postgres' ? 'postgresql' : db.scheme,
		    :host     => db_config.host,
		    :username => db_config.user,
		    :password => db_config.password,
		    :database => db_config.path[1..-1],
		    :encoding => Rails.env == 'development' ? 'unicode' : 'utf8'
		    )
      elsif
	    db_config = Rails.configuration.database_configuration[Rails.env]
  	  	TenantManager.establish_connection(:adapter =>db_config["adapter"],
	  	  										:encoding => db_config["encoding"],
	  	  										:database => db_config["database"],
	  											:pool => db_config["pool"],
	  											:username => db_config["username"],
	  											:password => db_config["password"],
	  											:port => db_config["port"])
	  end
      TenantManager.connection.schema_search_path = @current_tenant.subdomain#Uses Tenantmanger's connection   											
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
     if cookies[:auth_token] && !(cookies[:auth_token].empty?)
      @current_profile ||= UserProfile.find_by_auth_token!(cookies[:auth_token])
    else
      nil
    end
 end


end
