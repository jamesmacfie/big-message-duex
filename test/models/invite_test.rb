require "test_helper"

class InviteTest < ActiveSupport::TestCase
  self.use_transactional_tests = true

  def setup
    @user = User.create!(
      email: "inviter@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @user.confirm_email!
    @person = @user.person
  end

  test "should be valid with valid attributes" do
    invite = Invite.new(
      email: "invitee@example.com",
      invited_by: @person
    )
    assert invite.valid?
  end

  test "should require email" do
    invite = Invite.new(invited_by: @person)
    assert_not invite.valid?
    assert_includes invite.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    invite = Invite.new(
      email: "invalid-email",
      invited_by: @person
    )
    assert_not invite.valid?
    assert_includes invite.errors[:email], "is invalid"
  end

  test "should require invited_by" do
    invite = Invite.new(email: "invitee@example.com")
    assert_not invite.valid?
    assert_includes invite.errors[:invited_by], "must exist"
  end

  test "should generate token on create" do
    invite = Invite.create!(
      email: "invitee@example.com",
      invited_by: @person
    )
    assert_not_nil invite.token
    assert invite.token.length > 20
  end

  test "should have unique token" do
    invite1 = Invite.create!(
      email: "invitee1@example.com",
      invited_by: @person
    )
    invite2 = Invite.new(
      email: "invitee2@example.com",
      invited_by: @person,
      token: invite1.token
    )
    assert_not invite2.valid?
    assert_includes invite2.errors[:token], "has already been taken"
  end

  test "pending scope returns pending invites" do
    pending_invite = Invite.create!(
      email: "pending@example.com",
      invited_by: @person
    )
    accepted_invite = Invite.create!(
      email: "accepted@example.com",
      invited_by: @person
    )
    accepted_invite.accept!

    assert_includes Invite.pending, pending_invite
    assert_not_includes Invite.pending, accepted_invite
  end

  test "accepted scope returns accepted invites" do
    pending_invite = Invite.create!(
      email: "pending@example.com",
      invited_by: @person
    )
    accepted_invite = Invite.create!(
      email: "accepted@example.com",
      invited_by: @person
    )
    accepted_invite.accept!

    assert_includes Invite.accepted, accepted_invite
    assert_not_includes Invite.accepted, pending_invite
  end

  test "archived scope returns archived invites" do
    active_invite = Invite.create!(
      email: "active@example.com",
      invited_by: @person
    )
    archived_invite = Invite.create!(
      email: "archived@example.com",
      invited_by: @person
    )
    archived_invite.archive!

    assert_includes Invite.archived, archived_invite
    assert_not_includes Invite.archived, active_invite
  end

  test "accepted? returns true when accepted" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    assert_not invite.accepted?

    invite.accept!
    assert invite.accepted?
  end

  test "archived? returns true when archived" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    assert_not invite.archived?

    invite.archive!
    assert invite.archived?
  end

  test "valid_for_acceptance? returns true for pending invites" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    assert invite.valid_for_acceptance?
  end

  test "valid_for_acceptance? returns false for accepted invites" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    invite.accept!
    assert_not invite.valid_for_acceptance?
  end

  test "valid_for_acceptance? returns false for archived invites" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    invite.archive!
    assert_not invite.valid_for_acceptance?
  end

  test "accept! sets accepted_at timestamp" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    assert_nil invite.accepted_at

    invite.accept!
    assert_not_nil invite.accepted_at
    assert invite.accepted_at <= Time.current
  end

  test "archive! sets archived_at timestamp" do
    invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    assert_nil invite.archived_at

    invite.archive!
    assert_not_nil invite.archived_at
    assert invite.archived_at <= Time.current
  end

  test "creating new invite archives existing pending invites for same email" do
    first_invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    assert_nil first_invite.archived_at

    second_invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )

    first_invite.reload
    assert_not_nil first_invite.archived_at
    assert_nil second_invite.archived_at
  end

  test "creating new invite does not archive accepted invites for same email" do
    first_invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )
    first_invite.accept!
    accepted_at = first_invite.accepted_at

    second_invite = Invite.create!(
      email: "test@example.com",
      invited_by: @person
    )

    first_invite.reload
    assert_equal accepted_at, first_invite.accepted_at
    assert_nil first_invite.archived_at
  end
end
