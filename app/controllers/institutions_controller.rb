class InstitutionsController < ApplicationController
	
  load_and_authorize_resource	
  #Note that we are overriding the load resource by cancan in some actions.
  #This is because of the special case we are using (always loading the first
  #institution)

  def new
   # Only one institution can be created for a tenant
   if Institution.first
  	  redirect_to institution_root_path
   end
  	#@institution = Institution.new
  end

  def create
   	if Institution.first
      flash[:error] = "Institution already exists"
  	  redirect_to institution_root_path
   	end

    @institution = Institution.new(params[:institution])
    @institution.tenant_id = @current_tenant.id
    @institution.subdomain = @current_tenant.subdomain

    if @institution.save
      flash[:notice] = 'Institution successfully created'
      redirect_to institution_root_path
    else
      if @institution.errors[:tenant_id]
        flash[:error] = 'Invalid Tenant'
      elsif @institution.errors[:subdomain]
        flash[:error] = 'Invalid subdomain'
      end
      render :new
    end
  end
  
  def show
  	@institution = Institution.first
  	if !@institution
  	  redirect_to institution_new_path
  	end
  end

  def update
    #@institution = Institution.find(params[:id])
      if @institution.update_attributes(params[:institution])
      	flash[:notice] = 'Institution successfully updated'
        redirect_to institution_root_path
      else
        if @institution.errors[:tenant_id]
          flash[:error] = 'Invalid Tenant'
        elsif @institution.errors[:subdomain]
          flash[:error] = 'Invalid subdomain'
        end      	
        render :edit
      end
  end

  def edit
    @institution = Institution.first
  end

end
