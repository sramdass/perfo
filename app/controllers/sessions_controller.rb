class SessionsController < ApplicationController

  def new
  end

  def create
  	#We are not going to use the login field anymore. We will use the id_no from
  	#the faculty or student here. Yes, there is a login column, and it has to be removed
  	#if there is not anyother use.
  	t = Faculty.find_by_id_no(params[:login]) || Student.find_by_id_no(params[:login])
    profile = t.user_profile if t
    if profile && profile.valid_profile? && profile.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = profile.auth_token
      else
        cookies[:auth_token] = profile.auth_token
      end
      profile.last_login_at = Time.now
      profile.update_failed_login_count(true)
      redirect_to dashboard_path, :notice => "Logged in!"
    else
      profile.update_failed_login_count(false) if profile#Valid profile, but unsuccessful login
      flash.now.alert = "Invalid login or password"
      render :new
    end
    profile.save! if profile #Save the profile for the failed_login and the last_login only if it is valid
  end

  def destroy
  	#Recreate the auth_token when the user logs out. Otherwise some one can steal the token
  	#and use that for the next session
  	current_profile.generate_token(:auth_token)
  	current_profile.save!
    cookies.delete(:auth_token)
    redirect_to login_path, :notice => "Logged out!"
  end
  
  def dashboard
  end  

end
