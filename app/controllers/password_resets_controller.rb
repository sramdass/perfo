class PasswordResetsController < ApplicationController
  def new
   #Nothing's needed here. We are just getting the 'login' to send the password
  end

  def create
    profile = UserProfile.find_by_login(params[:login])
    profile.send_password_reset if profile
    redirect_to login_path, :notice => "Email sent with password reset instructions."
  end

  def edit
    @profile = UserProfile.find_by_password_reset_token!(params[:id])
  end

  def update
    @profile = UserProfile.find_by_password_reset_token!(params[:id])
    if @profile.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @profile.update_attributes(params[:user_profile])
      redirect_to login_path, :notice => "Password has been reset. Please login again!"
    else
      render :edit
    end
  end

end
