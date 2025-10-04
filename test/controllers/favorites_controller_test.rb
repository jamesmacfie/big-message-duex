require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", password: "password123", confirmed_at: Time.current)
    @person = Person.create!(name: "Test User", is_agent: false, user: @user)
    @channel = Channel.create!(name: "Test Channel", channel_type: "channel", created_by: @person)
    @channel.add_member(@person)
    sign_in_as(@user)
  end

  test "should create favorite" do
    assert_difference("Favorite.count", 1) do
      post channel_favorite_path(@channel), as: :turbo_stream
    end

    assert_response :success
    assert @person.favorites.exists?(channel: @channel)
  end

  test "should not create duplicate favorite" do
    Favorite.create!(person: @person, channel: @channel)

    assert_no_difference("Favorite.count") do
      post channel_favorite_path(@channel), as: :turbo_stream
    end

    assert_response :success
  end

  test "should destroy favorite" do
    favorite = Favorite.create!(person: @person, channel: @channel)

    assert_difference("Favorite.count", -1) do
      delete channel_favorite_path(@channel, favorite), as: :turbo_stream
    end

    assert_response :success
    assert_not @person.favorites.exists?(channel: @channel)
  end

  test "should require login to create favorite" do
    sign_out
    post channel_favorite_path(@channel)
    assert_redirected_to login_path
  end

  test "should require login to destroy favorite" do
    favorite = Favorite.create!(person: @person, channel: @channel)
    sign_out
    delete channel_favorite_path(@channel, favorite)
    assert_redirected_to login_path
  end

  test "should redirect to channel for html format on create" do
    post channel_favorite_path(@channel)
    assert_redirected_to @channel
  end

  test "should redirect to channel for html format on destroy" do
    favorite = Favorite.create!(person: @person, channel: @channel)
    delete channel_favorite_path(@channel, favorite)
    assert_redirected_to @channel
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password123" }
  end

  def sign_out
    delete logout_path
  end
end
