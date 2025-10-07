require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @channel = channels(:one)
    sign_in_as @user
  end

  test "should create regular message" do
    assert_difference("Message.count") do
      post channel_messages_path(@channel), params: {
        message: { content: "Hello world" }
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should accept client_temp_id parameter" do
    client_temp_id = "temp-#{Time.now.to_i}-#{SecureRandom.hex(8)}"

    assert_difference("Message.count") do
      post channel_messages_path(@channel), params: {
        message: { content: "Hello with temp id" },
        client_temp_id: client_temp_id
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should include client_temp_id in websocket broadcast" do
    client_temp_id = "temp-#{Time.now.to_i}-#{SecureRandom.hex(8)}"

    # Track what gets broadcast
    captured_broadcast_data = nil
    original_broadcast = ChatRoomChannel.method(:broadcast_to)

    ChatRoomChannel.define_singleton_method(:broadcast_to) do |channel, data|
      captured_broadcast_data = data
      # Don't actually broadcast in tests
    end

    post channel_messages_path(@channel), params: {
      message: { content: "Test message" },
      client_temp_id: client_temp_id
    }, as: :turbo_stream

    # Now verify the captured data
    assert_not_nil captured_broadcast_data, "ChatRoomChannel.broadcast_to should have been called"
    assert_equal "message", captured_broadcast_data[:type]
    assert_equal @user.person.id, captured_broadcast_data[:sender_id]
    assert_equal client_temp_id, captured_broadcast_data[:client_temp_id]
    assert_equal @channel.id, captured_broadcast_data[:channel_id]
    assert captured_broadcast_data[:message].present?, "Message HTML should be present"
  ensure
    # Restore original method
    ChatRoomChannel.define_singleton_method(:broadcast_to, original_broadcast) if original_broadcast
  end

  test "should handle nil client_temp_id gracefully" do
    assert_difference("Message.count") do
      post channel_messages_path(@channel), params: {
        message: { content: "Hello without temp id" },
        client_temp_id: nil
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should handle empty client_temp_id gracefully" do
    assert_difference("Message.count") do
      post channel_messages_path(@channel), params: {
        message: { content: "Hello with empty temp id" },
        client_temp_id: ""
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should pass through client_temp_id from params to broadcast" do
    # This test verifies the complete flow: params -> controller -> broadcast
    client_temp_id = "my-unique-temp-id-#{SecureRandom.hex(4)}"
    captured_broadcast_data = nil

    original_broadcast = ChatRoomChannel.method(:broadcast_to)
    ChatRoomChannel.define_singleton_method(:broadcast_to) do |channel, data|
      captured_broadcast_data = data
    end

    post channel_messages_path(@channel), params: {
      message: { content: "Test message" },
      client_temp_id: client_temp_id
    }, as: :turbo_stream

    assert_not_nil captured_broadcast_data, "Broadcast should have been called"
    assert_equal client_temp_id, captured_broadcast_data[:client_temp_id],
                 "client_temp_id should be passed through from params to broadcast"
  ensure
    ChatRoomChannel.define_singleton_method(:broadcast_to, original_broadcast) if original_broadcast
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password123" }
  end
end
