class TenantsController < ApplicationController
  def new
    @tenant = Tenant.new
  end
  
  def edit
  	@tenant = Tenant.find(params[:id])
  end

  def index
  	#@tenants = Tenant.all
  	#this expired query is not working. Need to fix this
    params[:q][:subscription_to_gt] = Date.today if params && params[:q] && params[:q][:subscription_to_gt]
  	@q = Tenant.search(params[:q])
    @tenants = @q.result(:distinct => true)
  end

  def show
  	@tenant = Tenant.find(params[:id])
  end
  
  def create
      @tenant = Tenant.new(params[:tenant])
      @tenant.activate_tenant
      if @tenant.save
        if params[:create_and_email]
          @tenant.send_activation_email
        end
        flash[:notice] = "Tenant successfully created"
        redirect_to tenants_path
      else
        render :new
      end
  end
  
  def update
    @tenant = Tenant.find(params[:id])
      if @tenant.update_attributes(params[:tenant])
      	flash[:notice] = 'Tenant successfully updated'
        redirect_to tenants_path
      else
        render :edit
      end
  end  
  
  def destroy
    Tenant.find(params[:id]).destroy
    redirect_to tenants_path
  end
  
  def invalid
  end
  
  def activate_options
    @tenant = Tenant.find_by_activation_token!(params[:id])  	
  end
  
  def activate
    @tenant = Tenant.find_by_activation_token!(params[:id])  	
    @tenant.subdomain = params[:tenant][:subdomain]
    if @tenant.subdomain && @tenant.save
      @tenant.create_profile(params[:tenant][:admin_login], params[:tenant][:password])
      @tenant.save!
      redirect_to login_url(:subdomain => @tenant.subdomain), :notice => "Account Activated. Please Login."
    else
      render :activate_options
    end
  end
  	
end
