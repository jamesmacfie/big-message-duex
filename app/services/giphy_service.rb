class GiphyService
  include HTTParty
  base_uri "https://api.giphy.com/v1"

  def initialize
    @api_key = ENV["GIPHY_API_KEY"]
  end

  def search(query, limit: 1)
    return { error: "Giphy API key not configured" } unless @api_key.present?

    response = self.class.get("/gifs/search", query: {
      api_key: @api_key,
      q: query,
      limit: limit,
      rating: "pg-13"
    })

    if response.success?
      parse_response(response)
    else
      { error: "Failed to fetch GIF from Giphy" }
    end
  rescue StandardError => e
    { error: "Giphy API error: #{e.message}" }
  end

  private

  def parse_response(response)
    data = response.parsed_response["data"]

    if data && data.any?
      {
        success: true,
        gifs: data.map do |gif|
          {
            id: gif["id"],
            title: gif["title"],
            url: gif["images"]["original"]["url"],
            preview_url: gif["images"]["fixed_height"]["url"],
            width: gif["images"]["original"]["width"],
            height: gif["images"]["original"]["height"]
          }
        end
      }
    else
      { error: "No GIFs found for that search" }
    end
  end
end
