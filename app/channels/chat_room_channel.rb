class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    channel = Channel.find(params[:channel_id])
    stream_for channel

    Rails.logger.info "ChatRoomChannel: User #{current_user.id} subscribed to channel #{channel.id}"
    Rails.logger.info "ChatRoomChannel: Stream name is #{stream_name_from(channel)}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ChatRoomChannel: Failed to find channel #{params[:channel_id]}: #{e.message}"
    reject
  end

  def unsubscribed
    Rails.logger.info "ChatRoomChannel: User #{current_user&.id} unsubscribed"
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def typing(data)
    channel = Channel.find(params[:channel_id])
    person = Person.find(data["person_id"])
    member = channel.members.find_by(person: person)

    if member
      member.typing!

      # Broadcast typing indicator to all other members
      payload = {
        type: "typing",
        person_id: person.id,
        person_name: person.name,
        typing_at: member.typing_at.iso8601
      }

      Rails.logger.debug "ChatRoomChannel: Broadcasting typing for person #{person.id} in channel #{channel.id}"
      ChatRoomChannel.broadcast_to(channel, payload)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ChatRoomChannel typing error: #{e.message}"
  end

  def stop_typing(data)
    channel = Channel.find(params[:channel_id])
    person = Person.find(data["person_id"])
    member = channel.members.find_by(person: person)

    if member
      member.stop_typing!

      # Broadcast stop typing to all other members
      payload = {
        type: "stop_typing",
        person_id: person.id
      }

      Rails.logger.debug "ChatRoomChannel: Broadcasting stop_typing for person #{person.id} in channel #{channel.id}"
      ChatRoomChannel.broadcast_to(channel, payload)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ChatRoomChannel stop_typing error: #{e.message}"
  end
end
