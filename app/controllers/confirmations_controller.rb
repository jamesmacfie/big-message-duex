class ConfirmationsController < ApplicationController
  def show
    user = User.find_by(email_confirmation_token: params[:token])

    if user
      user.confirm_email!
      flash[:notice] = "Email confirmed! You can now log in."
      redirect_to login_path
    else
      flash[:alert] = "Invalid confirmation token."
      redirect_to login_path
    end
  end
end
