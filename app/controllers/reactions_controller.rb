class ReactionsController < ApplicationController
  before_action :require_login
  before_action :require_confirmed_email
  before_action :set_message

  def create
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
      @reaction.save
      action = "added"
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
  end

  private

  def set_message
    @message = Message.find(params[:message_id])
  end
end
