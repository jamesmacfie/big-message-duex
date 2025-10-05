require "test_helper"

class SlashCommandParserTest < ActiveSupport::TestCase
  test "detects slash commands" do
    assert SlashCommandParser.is_command?("/gif cats")
    assert SlashCommandParser.is_command?("/help")
    refute SlashCommandParser.is_command?("regular message")
    refute SlashCommandParser.is_command?("not a /command in middle")
  end

  test "parses gif command" do
    parser = SlashCommandParser.new("/gif funny cats")
    result = parser.parse

    assert_equal "gif", result[:command]
    assert_equal "funny cats", result[:args]
  end

  test "parses command without arguments" do
    parser = SlashCommandParser.new("/help")
    result = parser.parse

    assert_equal "help", result[:command]
    assert_equal "", result[:args]
  end

  test "returns nil for non-commands" do
    parser = SlashCommandParser.new("regular message")
    assert_nil parser.parse
  end

  test "handles case insensitivity" do
    parser = SlashCommandParser.new("/GIF cats")
    result = parser.parse

    assert_equal "gif", result[:command]
  end
end
