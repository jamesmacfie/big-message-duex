class ChannelsController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_channel, only: [ :show, :edit, :update, :archive, :members_autocomplete ]
  before_action :authorize_channel_access, only: [ :show, :edit, :update, :archive, :members_autocomplete ]
  before_action :authorize_admin, only: [ :edit, :update, :archive ]

  def index
    @channels = current_user.person.accessible_channels.channels.active.order(:name)
  end

  def browse
    @all_channels = Channel.channels.active.public_channels.includes(:members, :people).order(:name)
    @user_channel_ids = current_user.person.accessible_channels.pluck(:id)
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(channel_params)
    @channel.created_by = current_user.person

    if @channel.save
      @channel.add_member(current_user.person, role: "admin")
      redirect_to @channel, notice: "Channel created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @channel = Channel.includes(members: :person).find(params[:id])
    @messages = @channel.messages.top_level.includes(:person, :attachments).ordered
    @message = Message.new
    @current_member = @channel.members.find_by(person: current_user.person)
    @current_member&.update_last_viewed!
  end

  def edit
  end

  def update
    if @channel.update(channel_params)
      redirect_to @channel, notice: "Channel updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    @channel.archive!
    redirect_to channels_path, notice: "Channel has been archived."
  end

  def members_autocomplete
    query = params[:query].to_s.strip
    members = @channel.members.includes(:person)

    if query.present?
      # Filter members by name matching the query
      people = members.map(&:person).select { |p| p.name.downcase.include?(query.downcase) }
    else
      people = members.map(&:person)
    end

    render json: people.map { |p| { id: p.id, name: p.name } }
  end

  private

  def set_channel
    @channel = Channel.find(params[:id])
  end

  def authorize_channel_access
    # Check if user is already a member
    return if @channel.member?(current_user.person)

    # Auto-join public channels
    if !@channel.is_private && @channel.channel_type == "channel"
      @channel.add_member(current_user.person)
      return
    end

    # Block access to private channels
    flash[:alert] = "You don't have access to this channel."
    redirect_to channels_path
  end

  def channel_params
    params.require(:channel).permit(:name, :description, :is_private)
  end

  def authorize_admin
    unless @channel.admin?(current_user.person)
      redirect_to @channel, alert: "Only channel admins can perform this action."
    end
  end
end
