class InstitutionsController < ApplicationController

  def new
   # Only one institution can be created for a tenant
   if Institution.first
  	  flash[:error] = "Institution already exists"
  	  redirect_to institution_path(Institution.first, :subdomain => request.subdomain)
   end
  	@institution = Institution.new
  end

  def create
   	if Institution.first
      flash[:error] = "Institution already exists"
  	  redirect_to institution_path(Institution.first, :subdomain => request.subdomain)
   	end
    @institution = Institution.new(params[:institution])
    if @institution.save
      flash[:notice] = 'Institution successfully created'
      redirect_to institution_path(Institution.first, :subdomain => request.subdomain)
    else
      render :new
    end
  end
  
  def show
  	@institution = Institution.find_by_subdomain(request.subdomain)
  end

  def update
    @institution = Institution.find(params[:id])
      if @institution.update_attributes(params[:institution])
      	flash[:notice] = 'Institution successfully updated'
        redirect_to dashboard_path
      else
        render :edit
      end
  end

  def edit
    @institution = Institution.find(params[:id])
  end

end
