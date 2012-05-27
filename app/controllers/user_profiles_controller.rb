class UserProfilesController < ApplicationController
  
  def index
  	@user_profiles=UserProfile.all
  end
  
  def new
    @user_profile = UserProfile.new
  end

  def create
  	#Make sure the 'login' field value corresponds to a faculty's or student's id_no
  	#It is not possible for a teacher and a student have the same id_no
    if params[:user_profile]
      if params[:user_profile][:profile_type] == true
    	user = Faculty.find_by_id_no(params[:user_profile][:login])
      else
      	user = Faculty.find_by_id_no(params[:user_profile][:login])
      end
    end
    if user
      @user_profile = UserProfile.new(params[:user_profile])
      @user_profile.tenant_id = Tenant.find_by_subdomain(request.subdomain).id
      @user_profile.user=user
      if @user_profile.save
        flash[:notice] = "Signed up! Please login."
        redirect_to login_path
      else
        render :new
      end
    else
      flash[:error] =  "Unable to sign up. Please contact the admin to add your profile"
      redirect_to signup_path
    end
  end
  
  def update
    @user_profile = UserProfile.find(params[:id])
    #We cannot update the roles directly, but go through the role_memberships.
    #Note in user_profile.rb
    role_mems = Array.new
    @user_profile.role_memberships.destroy_all
    if params[:role_ids]
      params[:role_ids].each do |role_id|
        role_mems << RoleMembership.new(:role_id => role_id, :user_profile_id => @user_profile.id)
      end
    end
    if role_mems.all?(&:valid?) && @user_profile.update_attributes(params[:user_profile])
      role_mems.each(&:save!) 
      flash[:notice] = "Profile successfully updated"
      redirect_to user_profile_path(@user_profile)
    else
      render :edit, :error => "Cannot update this user profile"
    end
  end

  def edit
    @user_profile = UserProfile.find(params[:id])
  end
    
  def show
    @user_profile = UserProfile.find(params[:id])
  end  
  
  def destroy
  	UserProfile.find(params[:id]).destroy
  	redirect_to user_profiles_path
  end
  
end
