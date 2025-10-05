class SlashCommandParser
  COMMAND_REGEX = /\A\/(\w+)\s*(.*)\z/

  def initialize(content)
    @content = content&.strip
  end

  def parse
    return nil unless @content&.start_with?("/")

    match = @content.match(COMMAND_REGEX)
    return nil unless match

    {
      command: match[1].downcase,
      args: match[2].strip
    }
  end

  def self.is_command?(content)
    content&.strip&.start_with?("/")
  end

  def self.execute(content, channel:, person:)
    parser = new(content)
    parsed = parser.parse

    return { error: "Invalid command format" } unless parsed

    case parsed[:command]
    when "gif"
      GifCommandHandler.new(parsed[:args], channel: channel, person: person).execute
    else
      { error: "Unknown command: /#{parsed[:command]}" }
    end
  end
end
