class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    channel = Channel.find(params[:channel_id])
    stream_for channel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
