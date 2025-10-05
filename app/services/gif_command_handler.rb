require "open-uri"

class GifCommandHandler
  def initialize(query, channel:, person:)
    @query = query
    @channel = channel
    @person = person
  end

  def execute
    return { error: "Please provide a search term (e.g., /gif funny cats)" } if @query.blank?

    giphy_service = GiphyService.new
    result = giphy_service.search(@query, limit: 1)

    if result[:error]
      return { error: result[:error] }
    end

    gif = result[:gifs].first
    create_message_with_gif(gif)
  end

  private

  def create_message_with_gif(gif)
    message = @channel.messages.build(
      content: "/gif #{@query}",
      person: @person
    )

    begin
      # Download the GIF from Giphy
      gif_file = URI.open(gif[:url])

      # Create the attachment
      attachment = message.attachments.build(
        file_name: "#{gif[:title].parameterize.presence || 'giphy'}.gif",
        content_type: "image/gif",
        file_size: gif_file.size
      )

      # Save the message first
      message.save!

      # Attach the file
      attachment.file.attach(
        io: gif_file,
        filename: attachment.file_name,
        content_type: "image/gif"
      )

      { success: true, message: message }
    rescue StandardError => e
      message.destroy if message.persisted?
      { error: "Failed to download GIF: #{e.message}" }
    end
  end
end
