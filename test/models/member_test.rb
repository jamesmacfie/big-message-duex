require "test_helper"

class MemberTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password123", confirmed_at: Time.current)
    @person = Person.create!(name: "Test User", is_agent: false, user: @user)
    @channel = Channel.create!(name: "Test Channel", channel_type: "channel", created_by: @person)
    @member = @channel.add_member(@person)
  end

  test "should belong to person" do
    assert_respond_to @member, :person
    assert_equal @person, @member.person
  end

  test "should belong to channel" do
    assert_respond_to @member, :channel
    assert_equal @channel, @member.channel
  end

  test "should validate role inclusion" do
    @member.role = "admin"
    assert @member.valid?

    @member.role = "member"
    assert @member.valid?

    @member.role = "invalid"
    assert_not @member.valid?
  end

  test "should validate uniqueness of person_id scoped to channel_id" do
    duplicate_member = Member.new(person: @person, channel: @channel)
    assert_not duplicate_member.valid?
    assert_includes duplicate_member.errors[:person_id], "has already been taken"
  end

  test "admin? should return true for admin role" do
    @member.update!(role: "admin")
    assert @member.admin?
  end

  test "admin? should return false for member role" do
    @member.update!(role: "member")
    assert_not @member.admin?
  end

  test "make_admin! should set role to admin" do
    @member.update!(role: "member")
    @member.make_admin!
    assert_equal "admin", @member.role
  end

  test "make_member! should set role to member" do
    @member.update!(role: "admin")
    @member.make_member!
    assert_equal "member", @member.role
  end

  test "update_last_viewed! should set last_viewed_at to current time" do
    assert_nil @member.last_viewed_at
    @member.update_last_viewed!
    assert_not_nil @member.last_viewed_at
    assert_in_delta Time.current, @member.last_viewed_at, 1.second
  end

  test "typing! should set typing_at to current time" do
    assert_nil @member.typing_at
    @member.typing!
    assert_not_nil @member.typing_at
    assert_in_delta Time.current, @member.typing_at, 1.second
  end

  test "stop_typing! should clear typing_at" do
    @member.typing!
    assert_not_nil @member.typing_at
    @member.stop_typing!
    assert_nil @member.typing_at
  end

  test "typing? should return true if typed recently" do
    @member.typing!
    assert @member.typing?
  end

  test "typing? should return false if not typed recently" do
    @member.update!(typing_at: 10.seconds.ago)
    assert_not @member.typing?
  end

  test "typing? should return false if typing_at is nil" do
    @member.update!(typing_at: nil)
    assert_not @member.typing?
  end

  test "unread_count should return 0 if last_viewed_at is nil" do
    assert_nil @member.last_viewed_at
    assert_equal 0, @member.unread_count
  end

  test "unread_count should return count of messages created after last_viewed_at" do
    @member.update!(last_viewed_at: 1.hour.ago)

    # Create messages at different times
    old_message = @channel.messages.create!(content: "Old message", person: @person, created_at: 2.hours.ago)
    new_message1 = @channel.messages.create!(content: "New message 1", person: @person, created_at: 30.minutes.ago)
    new_message2 = @channel.messages.create!(content: "New message 2", person: @person, created_at: 10.minutes.ago)

    assert_equal 2, @member.unread_count
  end

  test "unread_count should only count top-level messages, not thread replies" do
    @member.update!(last_viewed_at: 1.hour.ago)

    # Create a top-level message
    parent = @channel.messages.create!(content: "Parent message", person: @person, created_at: 30.minutes.ago)

    # Create thread replies
    reply1 = @channel.messages.create!(content: "Reply 1", person: @person, parent_message_id: parent.id, created_at: 20.minutes.ago)
    reply2 = @channel.messages.create!(content: "Reply 2", person: @person, parent_message_id: parent.id, created_at: 10.minutes.ago)

    # Should only count the parent message, not the replies
    assert_equal 1, @member.unread_count
  end

  test "has_unread? should return true if unread_count > 0" do
    @member.update!(last_viewed_at: 1.hour.ago)
    @channel.messages.create!(content: "New message", person: @person, created_at: 30.minutes.ago)

    assert @member.has_unread?
  end

  test "has_unread? should return false if unread_count is 0" do
    @member.update!(last_viewed_at: Time.current)
    assert_not @member.has_unread?
  end
end
