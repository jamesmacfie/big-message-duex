require "test_helper"

class SearchServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "user@example.com", password: "password123")
    @person = Person.create!(user: @user, name: "Test User")

    # Create channels
    @channel1 = Channel.create!(name: "general", description: "General discussion", created_by: @person, channel_type: "channel")
    @channel2 = Channel.create!(name: "random", description: "Random stuff", created_by: @person, channel_type: "channel")

    # Add person as member
    Member.create!(person: @person, channel: @channel1)
    Member.create!(person: @person, channel: @channel2)

    # Create messages
    @message1 = Message.create!(person: @person, channel: @channel1, content: "Hello everyone")
    @message2 = Message.create!(person: @person, channel: @channel1, content: "Testing the search functionality")

    @service = SearchService.new("test", @person)
  end

  test "search returns empty results for blank query" do
    service = SearchService.new("", @person)
    results = service.search

    assert_equal [], results[:channels]
    assert_equal [], results[:dms]
    assert_equal [], results[:messages]
  end

  test "search finds channels by name" do
    service = SearchService.new("general", @person)
    results = service.search

    assert_includes results[:channels].map { |c| c[:id] }, @channel1.id
  end

  test "search finds channels by description" do
    service = SearchService.new("discussion", @person)
    results = service.search

    assert_includes results[:channels].map { |c| c[:id] }, @channel1.id
  end

  test "search finds messages by content" do
    results = @service.search

    assert_includes results[:messages].map { |m| m[:id] }, @message2.id
  end

  test "search highlights matching text in messages" do
    results = @service.search
    message_result = results[:messages].find { |m| m[:id] == @message2.id }

    assert_includes message_result[:highlighted_content], "<mark>test</mark>"
  end

  test "search only returns accessible channels" do
    other_user = User.create!(email: "other@example.com", password: "password123")
    other_person = Person.create!(user: other_user, name: "Other User")
    private_channel = Channel.create!(name: "private", created_by: other_person, channel_type: "channel", is_private: true)

    service = SearchService.new("private", @person)
    results = service.search

    assert_not_includes results[:channels].map { |c| c[:id] }, private_channel.id
  end

  test "search excludes archived channels" do
    @channel1.update!(archived_at: Time.current)

    service = SearchService.new("general", @person)
    results = service.search

    assert_not_includes results[:channels].map { |c| c[:id] }, @channel1.id
  end

  test "search excludes deleted messages" do
    @message1.update!(deleted_at: Time.current)

    service = SearchService.new("hello", @person)
    results = service.search

    assert_not_includes results[:messages].map { |m| m[:id] }, @message1.id
  end

  test "search limits results per type" do
    # Create more than MAX_RESULTS_PER_TYPE messages
    15.times do |i|
      Message.create!(person: @person, channel: @channel1, content: "test message #{i}")
    end

    results = @service.search

    assert_operator results[:messages].size, :<=, SearchService::MAX_RESULTS_PER_TYPE
  end

  test "search finds DMs by participant name" do
    user2 = User.create!(email: "alice@example.com", password: "password123")
    person2 = Person.create!(user: user2, name: "Alice Smith")

    dm = Channel.create!(channel_type: "dm", created_by: @person)
    Member.create!(channel: dm, person: @person)
    Member.create!(channel: dm, person: person2)

    service = SearchService.new("alice", @person)
    results = service.search

    assert_includes results[:dms].map { |d| d[:id] }, dm.id
  end

  test "search is case insensitive" do
    service = SearchService.new("GENERAL", @person)
    results = service.search

    assert_includes results[:channels].map { |c| c[:id] }, @channel1.id
  end
end
