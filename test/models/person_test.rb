require "test_helper"

class PersonTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "user@example.com", password: "password123")
    @person = Person.new(user: @user, name: "Test User")
  end

  # Validations
  test "valid person" do
    assert @person.valid?
  end

  test "name is required" do
    @person.name = nil
    assert_not @person.valid?
    assert_includes @person.errors[:name], "can't be blank"
  end

  test "regular person must have user" do
    @person.user = nil
    @person.is_agent = false
    assert_not @person.valid?
    assert_includes @person.errors[:user], "Regular people must be associated with a user"
  end

  test "AI agent cannot have user" do
    @person.is_agent = true
    assert_not @person.valid?
    assert_includes @person.errors[:user], "AI agents cannot be associated with a user"
  end

  test "AI agent without user is valid" do
    agent = Person.new(name: "AI Assistant", is_agent: true)
    assert agent.valid?
  end

  # Scopes
  test "agents scope returns only agents" do
    agent = Person.create!(name: "Bot", is_agent: true)
    assert_includes Person.agents, agent
    assert_not_includes Person.agents, @person
  end

  test "humans scope returns only humans" do
    @person.save!
    agent = Person.create!(name: "Bot", is_agent: true)
    assert_includes Person.humans, @person
    assert_not_includes Person.humans, agent
  end

  # Associations
  test "person belongs to user" do
    assert_respond_to @person, :user
  end

  test "person has many channels through members" do
    assert_respond_to @person, :channels
  end

  test "person has many messages" do
    assert_respond_to @person, :messages
  end

  test "person has many favorites" do
    assert_respond_to @person, :favorites
  end

  # Methods
  test "accessible_channels returns active channels" do
    @person.save!
    channel = Channel.create!(name: "test", created_by: @person, channel_type: "channel")
    Member.create!(person: @person, channel: channel)

    assert_includes @person.accessible_channels, channel
  end

  test "accessible_channels excludes archived channels" do
    @person.save!
    channel = Channel.create!(name: "archived", created_by: @person, channel_type: "channel", archived_at: Time.current)
    Member.create!(person: @person, channel: channel)

    assert_not_includes @person.accessible_channels, channel
  end
end
