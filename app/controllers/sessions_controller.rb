class SessionsController < ApplicationController
  def new
  	if current_profile
  	  redirect_to institution_new_path
  	end
  end

  def create
    profile = UserProfile.find_by_login(params[:login])
    if profile && profile.valid_profile? && profile.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = profile.auth_token
      else
        cookies[:auth_token] = profile.auth_token
      end
      profile.last_login_at = Time.now
      profile.update_failed_login_count(true)
      redirect_to institution_new_path, :notice => "Logged in!"
    else
      profile.update_failed_login_count(false) if profile#Valid profile, but unsuccessful login
      flash.now.alert = "Invalid login or password"
      render :new
    end
    profile.save! if profile #Save the profile for the failed_login and the last_login only if it is valid
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to login_path, :notice => "Logged out!"
  end

end
