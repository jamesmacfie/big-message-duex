class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    channel = Channel.find(params[:channel_id])
    stream_for channel
  end

  def unsubscribed
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
      ChatRoomChannel.broadcast_to(
        channel,
        {
          type: "typing",
          person_id: person.id,
          person_name: person.name,
          typing_at: member.typing_at.iso8601
        }
      )
    end
  end

  def stop_typing(data)
    channel = Channel.find(params[:channel_id])
    person = Person.find(data["person_id"])
    member = channel.members.find_by(person: person)

    if member
      member.stop_typing!

      # Broadcast stop typing to all other members
      ChatRoomChannel.broadcast_to(
        channel,
        {
          type: "stop_typing",
          person_id: person.id
        }
      )
    end
  end
end
