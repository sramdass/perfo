class UserProfilesController < ApplicationController
  
  def index
  	@user_profiles=UserProfile.all
  end
  
  def new
    @user_profile = UserProfile.new
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
    if @user_profile.update_attributes(params[:user_profile])
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
  
end
