class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.confirmed?
        log_in(user)
        redirect_to root_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Please confirm your email address before logging in."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to login_path, notice: "Logged out successfully!"
  end
end
