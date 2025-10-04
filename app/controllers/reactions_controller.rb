class ReactionsController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_message
  before_action :authorize_channel_access
  before_action :check_message_not_deleted

  def create
    action = nil

    ActiveRecord::Base.transaction do
      @reaction = @message.reactions.find_or_initialize_by(
        person: current_user.person,
        emoji: params[:emoji]
      )

      if @reaction.persisted?
        # Reaction already exists, toggle it (delete)
        @reaction.destroy
        action = "removed"
      else
        # Create new reaction
        if @reaction.save
          action = "added"
        else
          # Validation failed
          respond_to do |format|
            format.turbo_stream { head :unprocessable_entity }
            format.html do
              flash[:alert] = "Invalid emoji"
              redirect_to @message.channel
            end
          end
          return
        end
      end
    end

    # Broadcast reaction update
    ChatRoomChannel.broadcast_to(
      @message.channel,
      {
        type: "reaction_#{action}",
        message_id: @message.id,
        emoji: params[:emoji],
        person_id: current_user.person.id,
        sender_id: current_user.person.id
      }
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "reactions-#{@message.id}",
          partial: "messages/reactions",
          locals: { message: @message }
        )
      end
      format.html { redirect_to @message.channel }
    end
  rescue ActiveRecord::RecordNotUnique
    # Handle race condition where another request created the same reaction
    retry
  end

  private

  def set_message
    @message = Message.find(params[:message_id])
  end

  def authorize_channel_access
    channel = @message.channel
    unless channel.member?(current_user.person)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html do
          flash[:alert] = "You don't have access to this channel."
          redirect_to channels_path
        end
      end
    end
  end

  def check_message_not_deleted
    if @message.deleted?
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html do
          flash[:alert] = "Cannot react to deleted messages."
          redirect_to @message.channel
        end
      end
    end
  end
end
