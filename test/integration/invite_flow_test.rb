require "test_helper"

class InviteFlowTest < ActionDispatch::IntegrationTest
  def setup
    @inviter = users(:one)
  end

  test "complete invite flow from send to acceptance" do
    # Step 1: Inviter logs in
    post login_url, params: { email: @inviter.email, password: "password123" }
    assert_redirected_to root_path
    follow_redirect!

    # Step 2: Inviter sends invite
    get new_invite_url
    assert_response :success

    assert_difference("Invite.count", 1) do
      post invites_url, params: { invite: { email: "newuser@example.com" } }
    end

    assert_redirected_to channels_path
    follow_redirect!

    # Get the invite that was created
    invite = Invite.find_by(email: "newuser@example.com")
    assert_not_nil invite
    assert_equal @inviter.person.id, invite.invited_by_id

    # Step 3: Log out inviter
    delete logout_url
    assert_redirected_to login_path

    # Step 4: New user clicks invite link (with token)
    get signup_url(invite_token: invite.token)
    assert_response :success

    # Step 5: New user signs up
    assert_difference("User.count", 1) do
      post signup_url, params: {
        invite_token: invite.token,
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    # Step 6: Should be logged in and redirected to channels
    assert_redirected_to channels_path
    follow_redirect!
    assert_response :success

    # Step 7: Verify invite is accepted
    invite.reload
    assert invite.accepted?
    assert_not_nil invite.accepted_at

    # Step 8: Verify user is confirmed (auto-confirmed via invite)
    new_user = User.find_by(email: "newuser@example.com")
    assert new_user.confirmed?
  end

  test "archived invites cannot be used" do
    # Create and archive an invite
    invite = Invite.create!(
      email: "archived@example.com",
      invited_by: @inviter.person
    )
    invite.archive!

    # Try to signup with archived invite
    get signup_url(invite_token: invite.token)

    # Should be redirected to login with error
    assert_redirected_to login_path
    assert_match /archived|used/i, flash[:alert]
  end

  test "already accepted invites cannot be used again" do
    # Create and accept an invite
    invite = Invite.create!(
      email: "accepted@example.com",
      invited_by: @inviter.person
    )
    invite.accept!

    # Try to signup with accepted invite
    get signup_url(invite_token: invite.token)

    # Should be redirected to login with error
    assert_redirected_to login_path
    assert_match /already been used/i, flash[:alert]
  end

  test "sending new invite archives previous pending invite for same email" do
    # Login as inviter
    post login_url, params: { email: @inviter.email, password: "password123" }

    # Send first invite
    post invites_url, params: { invite: { email: "test@example.com" } }
    first_invite = Invite.find_by(email: "test@example.com")
    assert_not_nil first_invite
    assert_nil first_invite.archived_at

    # Send second invite to same email
    post invites_url, params: { invite: { email: "test@example.com" } }
    second_invite = Invite.where(email: "test@example.com").order(created_at: :desc).first

    # First invite should be archived
    first_invite.reload
    assert_not_nil first_invite.archived_at

    # Second invite should be active
    assert_nil second_invite.archived_at
    assert_not_equal first_invite.id, second_invite.id
  end
end
