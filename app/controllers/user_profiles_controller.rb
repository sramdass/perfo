class UserProfilesController < ApplicationController
  
  def index
  	@profiles=UserProfile.all
  end
  
  def new
    @profile = UserProfile.new
  end

  def create
  	#Make sure the 'login' field value corresponds to a UserProfile's or student's id_no
    if params[:user_profile]
      if params[:user_profile][:profile_type] == true
    	user = Faculty.find_by_id_no(params[:user_profile][:login])
      else
      	user = Faculty.find_by_id_no(params[:user_profile][:login])
      end
    end
    if user
      @profile = UserProfile.new(params[:user_profile])
      @profile.tenant_id = Tenant.find_by_subdomain(request.subdomain).id
      @profile.user=user
      if @profile.save
        flash[:notice] = "Signed up! Please login."
        redirect_to signup_path
      else
        render :new
      end
    else
      flash[:error] =  "Unable to sign up. Please contact the admin to add your profile"
      redirect_to signup_path
    end
  end
  
  def update
  	# Here we are going to update only the roles for this user profile.
  	#None of the other fields of the user profiles are editable, for now.
  	#All the memberships corresponding to this user profile are deleted,
  	#and the new memberships are added. Yes, this is redundant! Performance
  	#needs to be tuned. TODO.
  	memberships = []
    @profile = UserProfile.find(params[:id])
    #NOTE: 
    #We cannot write -  old_memberships = @profile.role_memberships.
    #This seems to give a reference, not the absolute entries. If we do this.
    #after we build new memberships for this profile, the new ones also are
    #coming as a part of old_memberships. When we delete the old_memberships
    #the newly built ones will also get deleted, resulting in no roles for this profile.
	old_memberships = RoleMembership.for_user_profile(@profile.id)
    role_ids = params[:profile_roles] || []
    role_ids.each do |role_id|
      memberships << {:role_id => role_id}
    end
    @profile.role_memberships.build(memberships) 
    if @profile.role_memberships.all?(&:valid?) 
      if old_memberships
        old_memberships.each do |om|	
          om.destroy #--> This is the place I am referring above
        end
      end
      @profile.role_memberships.each(&:save!)
      flash[:notice] = "Roles successfully updated"
      redirect_to user_profile_path(@profile)
    else
      render :edit, :error => "Cannot updates roles to this user profile"
    end
  end

  def edit
    @profile = UserProfile.find(params[:id])
  end
    
  def show
    @profile = UserProfile.find(params[:id])
  end  
end
