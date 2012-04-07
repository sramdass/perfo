class TenantsController < ApplicationController
  def new
    @tenant = Tenant.new
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
        redirect_to tenants_path
      else
        render :new
      end
  end
  
  def destroy
    Tenant.find(params[:id]).destroy
    redirect_to tenants_path
  end
    
end
