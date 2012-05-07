class SessionsController < ApplicationController
  def new
  	if current_profile
  	  redirect_to institution_new_path
  	end
  end

  def create
    profile = UserProfile.find_by_login(params[:login])
    if profile && profile.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = profile.auth_token
      else
        cookies[:auth_token] = profile.auth_token
      end
       redirect_to institution_new_path, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid login or password"
      render :new
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to login_path, :notice => "Logged out!"
  end

end
