class MessagesController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_channel
  before_action :authorize_channel_access
  before_action :set_message, only: [:thread, :thread_indicator]

  def create
    @message = @channel.messages.build(message_params)
    @message.person = current_user.person

    if @message.save
      if @message.parent_message_id.present?
        # This is a thread reply - broadcast to thread subscribers
        ChatRoomChannel.broadcast_to(
          @channel,
          {
            type: "thread_reply",
            parent_message_id: @message.parent_message_id,
            reply: render_to_string(partial: "messages/thread_reply", locals: { reply: @message }),
            sender_id: current_user.person.id
          }
        )
      else
        # This is a top-level message - broadcast normally
        ChatRoomChannel.broadcast_to(
          @channel,
          {
            type: "message",
            message: render_to_string(partial: "messages/message", locals: { message: @message }),
            sender_id: current_user.person.id
          }
        )
      end

      respond_to do |format|
        if @message.parent_message_id.present?
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.remove("no-replies-#{@message.parent_message_id}"),
              turbo_stream.append("thread-replies-#{@message.parent_message_id}", partial: "messages/thread_reply", locals: { reply: @message })
            ]
          end
        else
          format.turbo_stream { render turbo_stream: turbo_stream.append("messages", partial: "messages/message", locals: { message: @message }) }
        end
        format.html { redirect_to @channel }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form", partial: "messages/form", locals: { channel: @channel, message: @message }) }
        format.html { redirect_to @channel, alert: "Failed to send message: #{@message.errors.full_messages.join(', ')}" }
      end
    end
  end

  def thread
    @replies = @message.replies.includes(:person).ordered
    @reply = Message.new(parent_message_id: @message.id)

    respond_to do |format|
      format.html { render partial: "messages/thread_panel", locals: { message: @message, replies: @replies, reply: @reply, channel: @channel } }
    end
  end

  def thread_indicator
    respond_to do |format|
      format.html { render partial: "messages/thread_indicator", locals: { message: @message } }
    end
  end

  private

  def set_message
    @message = @channel.messages.find(params[:id])
  end

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
    params.require(:message).permit(:content, :parent_message_id)
  end
end
