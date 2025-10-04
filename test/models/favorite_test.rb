require "test_helper"

class FavoriteTest < ActiveSupport::TestCase
  test "should belong to person" do
    favorite = Favorite.new
    assert_respond_to favorite, :person
  end

  test "should belong to channel" do
    favorite = Favorite.new
    assert_respond_to favorite, :channel
  end

  test "should validate uniqueness of person_id scoped to channel_id" do
    person = Person.create!(name: "Test User", is_agent: false, user: User.create!(email: "test@example.com", password: "password123", confirmed_at: Time.current))
    channel = Channel.create!(name: "Test Channel", channel_type: "channel", created_by: person)

    # Create first favorite
    favorite1 = Favorite.create!(person: person, channel: channel)
    assert favorite1.persisted?

    # Try to create duplicate favorite
    favorite2 = Favorite.new(person: person, channel: channel)
    assert_not favorite2.valid?
    assert_includes favorite2.errors[:person_id], "has already been taken"
  end

  test "should allow same person to favorite different channels" do
    person = Person.create!(name: "Test User", is_agent: false, user: User.create!(email: "test@example.com", password: "password123", confirmed_at: Time.current))
    channel1 = Channel.create!(name: "Channel 1", channel_type: "channel", created_by: person)
    channel2 = Channel.create!(name: "Channel 2", channel_type: "channel", created_by: person)

    favorite1 = Favorite.create!(person: person, channel: channel1)
    favorite2 = Favorite.create!(person: person, channel: channel2)

    assert favorite1.persisted?
    assert favorite2.persisted?
  end

  test "should allow different people to favorite same channel" do
    user1 = User.create!(email: "user1@example.com", password: "password123", confirmed_at: Time.current)
    user2 = User.create!(email: "user2@example.com", password: "password123", confirmed_at: Time.current)
    person1 = Person.create!(name: "User 1", is_agent: false, user: user1)
    person2 = Person.create!(name: "User 2", is_agent: false, user: user2)
    channel = Channel.create!(name: "Shared Channel", channel_type: "channel", created_by: person1)

    favorite1 = Favorite.create!(person: person1, channel: channel)
    favorite2 = Favorite.create!(person: person2, channel: channel)

    assert favorite1.persisted?
    assert favorite2.persisted?
  end
end
