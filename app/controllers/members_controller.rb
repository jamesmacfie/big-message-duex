class MembersController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_channel
  before_action :authorize_channel_access
  before_action :authorize_admin, only: [ :create, :update, :destroy ]
  before_action :set_member, only: [ :update, :destroy ]
  before_action :prevent_last_admin_removal, only: [ :update, :destroy ]

  def index
    @members = @channel.members.includes(:person).order("people.name")
  end

  def create
    person = Person.find(params[:person_id])

    if @channel.member?(person)
      redirect_to @channel, alert: "#{person.name} is already a member of this channel."
      return
    end

    @channel.add_member(person)
    redirect_to @channel, notice: "#{person.name} has been added to the channel."
  end

  def update
    if params[:action_type] == "promote"
      @member.make_admin!
      redirect_to @channel, notice: "#{@member.person.name} is now an admin."
    elsif params[:action_type] == "demote"
      @member.make_member!
      redirect_to @channel, notice: "#{@member.person.name} is now a regular member."
    else
      redirect_to @channel, alert: "Invalid action."
    end
  end

  def destroy
    person_name = @member.person.name

    # Allow members to leave the channel themselves
    if @member.person == current_user.person
      @member.destroy
      redirect_to channels_path, notice: "You have left the channel."
    elsif @channel.admin?(current_user.person)
      @member.destroy
      redirect_to @channel, notice: "#{person_name} has been removed from the channel."
    else
      redirect_to @channel, alert: "You don't have permission to remove members."
    end
  end

  private

  def set_channel
    @channel = Channel.find(params[:channel_id])
  end

  def set_member
    @member = @channel.members.find(params[:id])
  end

  def authorize_channel_access
    unless @channel.member?(current_user.person)
      redirect_to channels_path, alert: "You don't have access to this channel."
    end
  end

  def authorize_admin
    # Skip admin check if member is removing themselves
    return if action_name == "destroy" && params[:id] && @channel.members.find(params[:id]).person == current_user.person

    unless @channel.admin?(current_user.person)
      redirect_to @channel, alert: "Only channel admins can perform this action."
    end
  end

  def prevent_last_admin_removal
    return unless @member.admin?

    # Count admins (excluding the current member if they're being removed/demoted)
    admin_count = @channel.members.admins.count

    if admin_count <= 1
      if params[:action_type] == "demote" || action_name == "destroy"
        redirect_to @channel, alert: "Cannot remove or demote the last admin. Please promote another member first."
      end
    end
  end
end
