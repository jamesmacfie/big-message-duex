class InvitesController < ApplicationController
  before_action :require_login, only: [ :new, :create ]
  before_action :require_confirmed_email, only: [ :new, :create ]

  def new
    @invite = Invite.new
  end

  def create
    # Check if user already exists
    if User.exists?(email: invite_params[:email].downcase.strip)
      redirect_to channels_path, alert: "A user with this email already exists."
      return
    end

    @invite = current_user.person.sent_invites.build(invite_params)

    if @invite.save
      # Send invitation email
      InviteMailer.invitation_email(@invite).deliver_later
      redirect_to channels_path, notice: "Invitation sent to #{@invite.email}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def invite_params
    params.require(:invite).permit(:email)
  end
end
