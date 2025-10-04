class PasswordResetsController < ApplicationController
  before_action :find_user_by_token, only: [ :edit, :update ]
  before_action :check_token_expiration, only: [ :edit, :update ]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user
      user.generate_reset_token!
      # TODO: Send password reset email
      flash[:notice] = "Password reset instructions sent to your email."
    else
      flash[:notice] = "Password reset instructions sent to your email."
    end

    redirect_to login_path
  end

  def edit
  end

  def update
    if @user.reset_password!(params[:password])
      flash[:notice] = "Password has been reset successfully."
      redirect_to login_path
    else
      flash.now[:alert] = "Password must be at least 8 characters."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_user_by_token
    @user = User.find_by(reset_password_token: params[:id])
    unless @user
      flash[:alert] = "Invalid password reset token."
      redirect_to login_path
    end
  end

  def check_token_expiration
    if @user.reset_token_expired?
      flash[:alert] = "Password reset token has expired. Please request a new one."
      redirect_to new_password_reset_path
    end
  end
end
