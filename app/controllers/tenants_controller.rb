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
      if @tenant.save
        flash[:notice] = "Tenant created"
        if params[:create_and_add]
          redirect_to new_tenant_path
        else
          redirect_to tenants_path
        end
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
    
end
