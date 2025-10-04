class ChannelsController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_channel, only: [ :show ]
  before_action :authorize_channel_access, only: [ :show ]

  def index
    @channels = current_user.person.accessible_channels.channels.order(:name)
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
    @messages = @channel.messages.includes(:person).ordered
    @message = Message.new
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
end
