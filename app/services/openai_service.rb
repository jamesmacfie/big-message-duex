class OpenaiService
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def initialize
    @api_key = ENV["OPENAI_API_KEY"]
    @options = {
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }
    }
  end

  def chat_completion(messages:, model: "gpt-4o", temperature: 0.7, max_tokens: 1000)
    return { error: "OpenAI API key not configured" } unless @api_key.present?

    body = {
      model: model,
      messages: messages,
      temperature: temperature,
      max_tokens: max_tokens
    }

    response = self.class.post("/chat/completions", @options.merge(body: body.to_json))

    if response.success?
      {
        success: true,
        content: response.parsed_response.dig("choices", 0, "message", "content"),
        usage: response.parsed_response["usage"]
      }
    else
      error_message = response.parsed_response.dig("error", "message") || "Unknown error"
      Rails.logger.error("OpenAI API error: #{error_message}")
      { error: error_message }
    end
  rescue StandardError => e
    Rails.logger.error("OpenAI API exception: #{e.message}")
    { error: "Failed to communicate with OpenAI: #{e.message}" }
  end

  def build_conversation_messages(system_prompt:, history: [])
    messages = [{ role: "system", content: system_prompt }]

    history.each do |msg|
      messages << {
        role: msg[:is_agent] ? "assistant" : "user",
        content: msg[:content]
      }
    end

    messages
  end
end
