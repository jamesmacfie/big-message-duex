require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "user@example.com", password: "password123")
    @person = Person.create!(user: @user, name: "Test User")
    @channel = Channel.create!(name: "general", created_by: @person, channel_type: "channel")
    @message = Message.new(person: @person, channel: @channel, content: "Hello world")
  end

  # Validations
  test "valid message" do
    assert @message.valid?
  end

  test "person is required" do
    @message.person = nil
    assert_not @message.valid?
  end

  test "channel is required" do
    @message.channel = nil
    assert_not @message.valid?
  end

  test "content can be blank for attachments" do
    @message.content = ""
    assert @message.valid?
  end

  # Associations
  test "message belongs to person" do
    assert_equal @person, @message.person
  end

  test "message belongs to channel" do
    assert_equal @channel, @message.channel
  end

  test "message has many reactions" do
    assert_respond_to @message, :reactions
  end

  test "message has many mentions" do
    assert_respond_to @message, :mentions
  end

  test "message can have parent message for threading" do
    @message.save!
    reply = Message.create!(person: @person, channel: @channel, content: "Reply", parent_message: @message)
    assert_equal @message, reply.parent_message
  end

  # Scopes
  test "top_level scope excludes threaded replies" do
    @message.save!
    reply = Message.create!(person: @person, channel: @channel, content: "Reply", parent_message: @message)

    assert_includes Message.top_level, @message
    assert_not_includes Message.top_level, reply
  end

  test "ordered scope returns messages in chronological order" do
    @message.save!
    later = Message.create!(person: @person, channel: @channel, content: "Later", created_at: 1.minute.from_now)

    messages = Message.ordered.to_a
    assert_equal @message, messages.first
    assert_equal later, messages.last
  end

  # Methods
  test "edited? returns true for edited messages" do
    @message.edited_at = Time.current
    assert @message.edited?
  end

  test "edited? returns false for unedited messages" do
    assert_not @message.edited?
  end

  test "deleted? returns true for soft-deleted messages" do
    @message.deleted_at = Time.current
    assert @message.deleted?
  end

  test "deleted? returns false for active messages" do
    assert_not @message.deleted?
  end
end
