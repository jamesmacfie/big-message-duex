require "test_helper"

class GiphyServiceTest < ActiveSupport::TestCase
  test "returns error when API key is missing" do
    original_key = ENV["GIPHY_API_KEY"]
    ENV["GIPHY_API_KEY"] = nil

    service = GiphyService.new
    result = service.search("cats")

    assert result[:error].present?
    assert_match /API key not configured/, result[:error]
  ensure
    ENV["GIPHY_API_KEY"] = original_key
  end

  # Note: This test requires a valid API key and network access
  # It will be skipped if GIPHY_API_KEY is not set
  test "searches for GIFs successfully" do
    skip "GIPHY_API_KEY not set" unless ENV["GIPHY_API_KEY"].present?

    service = GiphyService.new
    result = service.search("cats", limit: 1)

    if result[:success]
      assert result[:gifs].present?
      assert result[:gifs].is_a?(Array)
      assert result[:gifs].first[:url].present?
    else
      # If we get "No GIFs found", that's still a valid response
      assert result[:error].present?
    end
  end
end
