class MessagesController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_channel
  before_action :authorize_channel_access

  def create
    @message = @channel.messages.build(message_params)
    @message.person = current_user.person

    if @message.save
      # Broadcast the new message to all subscribers
      ChatRoomChannel.broadcast_to(
        @channel,
        {
          message: render_to_string(partial: "messages/message", locals: { message: @message }),
          sender_id: current_user.person.id
        }
      )

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @message }) }
        format.html { redirect_to @channel }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form", partial: "messages/form", locals: { channel: @channel, message: @message }) }
        format.html { redirect_to @channel, alert: "Failed to send message: #{@message.errors.full_messages.join(', ')}" }
      end
    end
  end

  private

  def set_channel
    @channel = Channel.find(params[:channel_id])
  end

  def authorize_channel_access
    unless @channel.member?(current_user.person) || (!@channel.is_private && @channel.channel_type == "channel")
      flash[:alert] = "You don't have access to this channel."
      redirect_to channels_path
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
