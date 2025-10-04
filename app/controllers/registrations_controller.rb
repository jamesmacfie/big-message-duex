class RegistrationsController < ApplicationController
  before_action :load_invite, only: [ :new, :create ]

  def new
    @user = User.new
    @user.email = @invite.email if @invite
  end

  def create
    @user = User.new(user_params)

    if @user.save
      # If signing up via invite, auto-confirm and login
      if @invite
        @invite.accept!
        @user.confirm_email!
        session[:user_id] = @user.id
        redirect_to channels_path, notice: "Welcome to Big Message! Your account has been created."
      else
        # Normal signup flow requires email confirmation
        @user.generate_confirmation_token!
        UserMailer.confirmation_email(@user).deliver_later
        flash[:notice] = "Please check your email to confirm your account."
        redirect_to login_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def load_invite
    return unless params[:invite_token]

    @invite = Invite.find_by(token: params[:invite_token])

    if @invite && !@invite.valid_for_acceptance?
      flash[:alert] = "This invitation has been archived or has already been used."
      redirect_to login_path
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
