require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @person = @user.person
  end

  test "should get new when logged in" do
    sign_in_as(@user)
    get new_invite_url
    assert_response :success
  end

  test "should redirect to login when not logged in" do
    get new_invite_url
    assert_redirected_to login_path
  end

  test "should create invite with valid email" do
    sign_in_as(@user)

    assert_difference("Invite.count") do
      post invites_url, params: { invite: { email: "newuser@example.com" } }
    end

    assert_redirected_to channels_path
    assert_equal "Invitation sent to newuser@example.com", flash[:notice]

    # Check invite was created
    invite = Invite.last
    assert_equal "newuser@example.com", invite.email
    assert_equal @person.id, invite.invited_by_id
  end

  test "should not create invite for existing user" do
    sign_in_as(@user)
    existing_email = users(:two).email

    assert_no_difference("Invite.count") do
      post invites_url, params: { invite: { email: existing_email } }
    end

    assert_redirected_to channels_path
    assert_equal "A user with this email already exists.", flash[:alert]
  end

  test "should not create invite with invalid email" do
    sign_in_as(@user)

    assert_no_difference("Invite.count") do
      post invites_url, params: { invite: { email: "invalid-email" } }
    end

    assert_response :unprocessable_entity
  end

  test "should archive existing pending invites for same email" do
    sign_in_as(@user)

    # Create first invite
    first_invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )

    # Create second invite for same email
    assert_difference("Invite.count", 1) do
      post invites_url, params: { invite: { email: "test@example.com" } }
    end

    # First invite should be archived
    first_invite.reload
    assert_not_nil first_invite.archived_at
  end

  test "should require login to create invite" do
    assert_no_difference("Invite.count") do
      post invites_url, params: { invite: { email: "test@example.com" } }
    end

    assert_redirected_to login_path
  end

  test "should require confirmed email to create invite" do
    unconfirmed_user = User.create!(
      email: "unconfirmed@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    # Try to login with unconfirmed user
    post login_url, params: { email: unconfirmed_user.email, password: "password123" }

    # Should render login page with error because email not confirmed
    assert_response :unprocessable_entity
    assert_match /confirm your email/i, flash[:alert]
  end

  private

  def sign_in_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end
end
