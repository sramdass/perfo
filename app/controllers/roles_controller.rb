class RolesController < ApplicationController
  load_and_authorize_resource
  
  def index
  	#@roles = Role.all
  end

  def show
    #@role = Role.find(params[:id])
  end

  def new
    #@role = Role.new
  end

  def edit
    #@role = Role.find(params[:id])
  end

  def create
  	#@role = Role.new(params[:role])
    perms = []
    privilege = params[:privilege]
    Resource.all.each do |res|
      #Permissions corresponding to all the resources should come as parameters. 
      #If none of the permissions are selected for a particular resource, we should get
      #0 as default.
	  perms << {:resource_id=> res.id, :privilege => privilege["#{res.id}"]}
    end
    @role.permissions.build(perms) if !perms.empty?
    if @role.valid? && @role.permissions.all?(&:valid?)
  	  @role.save!
  	  @role.permissions.each(&:save!)
      redirect_to(@role, :notice => 'Role was successfully created.') 
    else
      render :new
    end
  end

  def update
    #@role = Role.find(params[:id])
    privilege = params[:privilege]
    Resource.all.each do |res|
      #Permissions corresponding to all the resources should come as parameters. 
      #If none of the permissions are selected for a particular resource, we should get
      #0 as default.    	
      
      #Yes, we are updating the privilege before we update the role attributes and there will
      #be a need for rollback if the role's attributes cannot be save for some reason.
      #I DO NOT know how to handle these at this moment.
      
      #I have also assumed that the permissions for all the resources are in the db once the role is created.
      #Might face some problems if u change the data directly in the database
      @role.permissions.find_by_resource_id(res.id).update_attributes({:privilege => privilege["#{res.id}"]})
    end    
    if @role.update_attributes(params[:role])
      redirect_to @role, :notice => 'Role was successfully updated'
    else
      render :edit
    end
  end

  def destroy
    #@role = Role.find(params[:id])
    @role.destroy
     redirect_to roles_path
  end

end
