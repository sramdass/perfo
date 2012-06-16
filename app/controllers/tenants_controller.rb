class TenantsController < ApplicationController
  #skip the activate_options and activate actions from cancan
  load_and_authorize_resource	:only => [:new, :edit, :index, :show, :create, :update, :destroy]
  def new
    #@tenant = Tenant.new
  end
  
  def edit
  	#@tenant = Tenant.find(params[:id])
  end

  def index
  	#@tenants = Tenant.all
  	#this expired query is not working. Need to fix this
    params[:q][:subscription_to_gt] = Date.today if params && params[:q] && params[:q][:subscription_to_gt]
  	@q = Tenant.search(params[:q])
    @tenants = @q.result(:distinct => true).accessible_by(current_ability)
  end

  def show
  	#@tenant = Tenant.find(params[:id])
  end
  
  def create
    #@tenant = Tenant.new(params[:tenant])
    if @tenant.save
      flash[:notice] = "Tenant successfully created"
      redirect_to tenants_path
    else
      render :new
    end
  end
  
  def update
    #@tenant = Tenant.find(params[:id])
    if @tenant.update_attributes(params[:tenant])
      flash[:notice] = 'Tenant successfully updated'
      redirect_to tenants_path
    else
      render :edit
    end
  end  
  
  def destroy
    #@tenant = Tenant.find(params[:id])
    @tenant.destroy
    redirect_to tenants_path
  end

  
  def activate_options
    @tenant = Tenant.find_by_activation_token!(params[:key])  	
  end
  
  def activate
  	#Even though this is the same tenant we have sent in the activate_options, we cannot find the
  	#tenant by params[:id]. Anyone can send a valid id with a post request.
    @tenant = Tenant.find_by_activation_token!(params[:key])  	
    #Make the current activation token invalid by creating a new one
    #@tenant = Tenant.find(params[:id])
    @tenant.subdomain = params[:tenant][:subdomain]
    if @tenant.subdomain && @tenant.save && @tenant.create_profile(params[:tenant][:admin_login], params[:tenant][:password], params[:tenant][:password_confirmation])
      @tenant.activation_token = random_string #Make sure the current token becomes invalid
      @tenant.save! #Save the activation token here
      flash[:notice] = "Account activated. Please login!"
      redirect_to login_url(:subdomain => @tenant.subdomain)
    else
      @tenant.clear_profile
      flash[:notice] = "Account activation failed"
      render :activate_options
    end
  end
  	
end
