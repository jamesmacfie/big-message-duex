require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @channel = channels(:one)
    sign_in @user
  end

  test "should create regular message" do
    assert_difference("Message.count") do
      post channel_messages_path(@channel), params: {
        message: { content: "Hello world" }
      }, as: :turbo_stream
    end

    assert_response :success
  end

  test "should handle /gif command without search term" do
    assert_no_difference("Message.count") do
      post channel_messages_path(@channel), params: {
        message: { content: "/gif" }
      }, as: :turbo_stream
    end

    assert_response :success
    assert_match /provide a search term/i, response.body
  end

  test "should recognize /gif command" do
    # Mock the GiphyService to avoid real API calls in tests
    mock_result = {
      success: true,
      message: Message.new(id: 999, content: "/gif cats", person: @user.person)
    }

    SlashCommandParser.stub :execute, mock_result do
      post channel_messages_path(@channel), params: {
        message: { content: "/gif cats" }
      }, as: :turbo_stream

      assert_response :success
    end
  end

  private

  def sign_in(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
