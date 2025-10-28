require "test_helper"

class ChannelTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "user@example.com", password: "password123")
    @person = Person.create!(user: @user, name: "Test User")
    @channel = Channel.new(name: "general", created_by: @person, channel_type: "channel")
  end

  # Validations
  test "valid channel" do
    assert @channel.valid?
  end

  test "created_by is required" do
    @channel.created_by = nil
    assert_not @channel.valid?
  end

  test "channel_type is required" do
    @channel.channel_type = nil
    assert_not @channel.valid?
  end

  # Scopes
  test "active scope excludes archived channels" do
    @channel.save!
    archived = Channel.create!(name: "old", created_by: @person, channel_type: "channel", archived_at: Time.current)

    assert_includes Channel.active, @channel
    assert_not_includes Channel.active, archived
  end

  test "channels scope returns only channels" do
    @channel.save!
    dm = Channel.create!(name: nil, created_by: @person, channel_type: "dm")

    assert_includes Channel.channels, @channel
    assert_not_includes Channel.channels, dm
  end

  test "dms scope returns only DMs" do
    @channel.save!
    dm = Channel.create!(name: nil, created_by: @person, channel_type: "dm")

    assert_includes Channel.dms, dm
    assert_not_includes Channel.dms, @channel
  end

  # Associations
  test "channel has many members" do
    assert_respond_to @channel, :members
  end

  test "channel has many messages" do
    assert_respond_to @channel, :messages
  end

  test "channel belongs to created_by person" do
    assert_equal @person, @channel.created_by
  end

  # Methods
  test "dm? returns true for DM channels" do
    dm = Channel.new(channel_type: "dm", created_by: @person)
    assert dm.dm?
  end

  test "dm? returns false for regular channels" do
    assert_not @channel.dm?
  end

  test "archived? returns true for archived channels" do
    @channel.archived_at = Time.current
    assert @channel.archived?
  end

  test "archived? returns false for active channels" do
    assert_not @channel.archived?
  end

  test "dm_name_for returns other participants names" do
    user2 = User.create!(email: "user2@example.com", password: "password123")
    person2 = Person.create!(user: user2, name: "Other User")

    dm = Channel.create!(channel_type: "dm", created_by: @person)
    Member.create!(channel: dm, person: @person)
    Member.create!(channel: dm, person: person2)

    assert_equal "Other User", dm.dm_name_for(@person)
  end
end
