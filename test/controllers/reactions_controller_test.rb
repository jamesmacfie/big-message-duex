require "test_helper"

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @person = people(:one)
    @message = messages(:one)
    @channel = channels(:one)
    # Ensure user is a member of the channel
    @member = members(:one)
  end

  def login_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end

  test "should create reaction when user is authenticated and member of channel" do
    login_as(@user)

    assert_difference("Reaction.count", 1) do
      post message_reactions_path(@message), params: { emoji: "👍" }, as: :turbo_stream
    end

    assert_response :success
    assert_equal "👍", Reaction.last.emoji
    assert_equal @person.id, Reaction.last.person_id
  end

  test "should remove reaction when user clicks same emoji again (toggle)" do
    login_as(@user)

    # First create a reaction
    reaction = @message.reactions.create!(person: @person, emoji: "❤️")

    assert_difference("Reaction.count", -1) do
      post message_reactions_path(@message), params: { emoji: "❤️" }, as: :turbo_stream
    end

    assert_response :success
    assert_not Reaction.exists?(reaction.id)
  end

  test "should not allow reaction when user is not logged in" do
    assert_no_difference("Reaction.count") do
      post message_reactions_path(@message), params: { emoji: "👍" }, as: :turbo_stream
    end

    assert_redirected_to login_path
  end

  test "should not allow reaction when user is not member of channel" do
    other_user = users(:two)
    other_message = messages(:two)
    login_as(@user)

    # User one is not a member of channel two
    assert_no_difference("Reaction.count") do
      post message_reactions_path(other_message), params: { emoji: "👍" }, as: :turbo_stream
    end

    assert_response :forbidden
  end

  test "should not allow reaction on deleted message" do
    login_as(@user)
    @message.update(deleted_at: Time.current, content: "[deleted]")

    assert_no_difference("Reaction.count") do
      post message_reactions_path(@message), params: { emoji: "👍" }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test "should reject invalid emoji" do
    login_as(@user)

    assert_no_difference("Reaction.count") do
      post message_reactions_path(@message), params: { emoji: "not an emoji" }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
  end

  test "should allow multiple different emojis on same message" do
    login_as(@user)

    post message_reactions_path(@message), params: { emoji: "👍" }, as: :turbo_stream
    assert_response :success

    assert_difference("Reaction.count", 1) do
      post message_reactions_path(@message), params: { emoji: "❤️" }, as: :turbo_stream
    end

    assert_response :success
    assert_equal 2, @message.reactions.where(person: @person).count
  end
end
