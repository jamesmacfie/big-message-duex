require "test_helper"

class ReactionTest < ActiveSupport::TestCase
  setup do
    @message = messages(:one)
    @person = people(:one)
  end

  test "should create valid reaction with emoji" do
    reaction = Reaction.new(message: @message, person: @person, emoji: "👍")
    assert reaction.valid?
  end

  test "should accept various emoji types" do
    valid_emojis = ["😀", "❤️", "🎉", "👍", "🔥", "😂"]

    valid_emojis.each do |emoji|
      reaction = Reaction.new(message: @message, person: @person, emoji: emoji)
      assert reaction.valid?, "#{emoji} should be valid"
    end
  end

  test "should reject non-emoji strings" do
    invalid_strings = ["abc", "123", "not an emoji"]

    invalid_strings.each do |string|
      reaction = Reaction.new(message: @message, person: @person, emoji: string)
      assert_not reaction.valid?, "#{string.inspect} should be invalid"
      assert_includes reaction.errors[:emoji], "must be a valid emoji"
    end
  end

  test "should require emoji presence" do
    reaction = Reaction.new(message: @message, person: @person, emoji: nil)
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "can't be blank"
  end

  test "should enforce emoji length limit" do
    reaction = Reaction.new(message: @message, person: @person, emoji: "😀" * 20)
    assert_not reaction.valid?
    assert_includes reaction.errors[:emoji], "is too long (maximum is 10 characters)"
  end

  test "should enforce uniqueness per person, message, and emoji" do
    Reaction.create!(message: @message, person: @person, emoji: "👍")

    duplicate = Reaction.new(message: @message, person: @person, emoji: "👍")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:person_id], "has already been taken"
  end

  test "should allow same emoji on different messages" do
    other_message = messages(:two)
    Reaction.create!(message: @message, person: @person, emoji: "👍")

    reaction = Reaction.new(message: other_message, person: @person, emoji: "👍")
    assert reaction.valid?
  end

  test "should allow different people to use same emoji on same message" do
    other_person = people(:two)
    Reaction.create!(message: @message, person: @person, emoji: "👍")

    reaction = Reaction.new(message: @message, person: other_person, emoji: "👍")
    assert reaction.valid?
  end
end
