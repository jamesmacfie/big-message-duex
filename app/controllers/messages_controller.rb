class MessagesController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_channel, except: [:reactions_partial]
  before_action :authorize_channel_access, except: [:reactions_partial]
  before_action :set_message, only: [:show, :thread, :thread_indicator, :update, :destroy]
  before_action :set_message_without_channel, only: [:reactions_partial]
  before_action :authorize_message_owner, only: [:update, :destroy]

  def create
    @message = @channel.messages.build(message_params)
    @message.person = current_user.person

    begin
      ActiveRecord::Base.transaction do
        @message.save!

        # Handle file attachments if present
        if params[:message][:files].present?
          params[:message][:files].each do |file|
            attachment = @message.attachments.create!(
              file_name: file.original_filename,
              content_type: file.content_type,
              file_size: file.size
            )
            attachment.file.attach(file)
          end
        end
      end

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
            sender_id: current_user.person.id,
            channel_id: @channel.id
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
    rescue ActiveRecord::RecordInvalid => e
      @message.errors.add(:base, e.message)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("message-form", partial: "messages/form", locals: { channel: @channel, message: @message }) }
        format.html { redirect_to @channel, alert: "Failed to send message: #{@message.errors.full_messages.join(', ')}" }
      end
    end
  end

  def show
    respond_to do |format|
      format.html do
        render partial: @message.thread? ? "messages/thread_reply" : "messages/message",
               locals: @message.thread? ? { reply: @message } : { message: @message }
      end
    end
  end

  def thread
    @replies = @message.replies.includes(:person, :attachments).ordered
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

  def reactions_partial
    respond_to do |format|
      format.html { render partial: "messages/reactions", locals: { message: @message } }
    end
  end

  def update
    if @message.update(message_params)
      @message.mark_as_edited!

      # Broadcast the updated message
      ChatRoomChannel.broadcast_to(
        @channel,
        {
          type: "message_updated",
          message_id: @message.id,
          content: @message.content,
          edited: true,
          sender_id: current_user.person.id
        }
      )

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message-#{@message.id}",
            partial: @message.thread? ? "messages/thread_reply" : "messages/message",
            locals: @message.thread? ? { reply: @message } : { message: @message }
          )
        end
        format.html { redirect_to @channel }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to @channel, alert: "Failed to update message" }
      end
    end
  end

  def destroy
    @message.update(content: "[deleted]", deleted_at: Time.current)

    # Broadcast the deleted message
    ChatRoomChannel.broadcast_to(
      @channel,
      {
        type: "message_deleted",
        message_id: @message.id,
        sender_id: current_user.person.id
      }
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "message-#{@message.id}",
          partial: @message.thread? ? "messages/thread_reply" : "messages/message",
          locals: @message.thread? ? { reply: @message } : { message: @message }
        )
      end
      format.html { redirect_to @channel }
    end
  end

  private

  def set_message
    @message = @channel.messages.find(params[:id])
  end

  def set_message_without_channel
    @message = Message.find(params[:id])
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

  def authorize_message_owner
    unless @message.person_id == current_user.person.id
      flash[:alert] = "You can only edit or delete your own messages."
      redirect_to @channel
    end
  end

  def message_params
    params.require(:message).permit(:content, :parent_message_id, files: [])
  end
end
