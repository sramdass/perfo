class TenantsController < ApplicationController
  def new
    @tenant = Tenant.new
  end

  def index
  end

  def show
  end
  
  def create
      @tenant = Tenant.new(params[:tenant])
      if @tenant.save
       flash[:notice] = "Signed up!"
        redirect_to tenants_path
      else
        render :new
      end
  end
end
