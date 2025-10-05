class AiAgentResponder
  CONVERSATION_HISTORY_LIMIT = 20 # Last 20 messages

  def self.respond_to_message(message)
    new(message).respond
  end

  def initialize(message)
    @message = message
    @channel = message.channel
    @sender = message.person
  end

  def respond
    # Only respond in DMs
    return unless @channel.dm?

    # Find the AI agent in this DM
    agent = find_agent_in_dm
    return unless agent

    # Don't respond if the message is from the agent itself
    return if @sender.is_agent?

    # Generate and post the AI response
    generate_and_post_response(agent)
  end

  private

  def find_agent_in_dm
    @channel.people.agents.first
  end

  def generate_and_post_response(agent)
    # Set typing indicator for the agent
    set_agent_typing(agent, true)

    # Build conversation history
    conversation_history = build_conversation_history

    # Create OpenAI service
    openai = OpenaiService.new

    # Build messages for OpenAI
    messages = openai.build_conversation_messages(
      system_prompt: agent.agent_prompt || default_agent_prompt(agent),
      history: conversation_history
    )

    # Get response from OpenAI
    result = openai.chat_completion(messages: messages)

    # Clear typing indicator
    set_agent_typing(agent, false)

    if result[:success]
      # Create message from agent
      agent_message = @channel.messages.create!(
        person: agent,
        content: result[:content]
      )

      # Broadcast the agent's message
      broadcast_agent_message(agent_message)
    else
      Rails.logger.error("AI Agent error: #{result[:error]}")
      # Optionally send an error message
      error_message = @channel.messages.create!(
        person: agent,
        content: "I apologize, but I'm having trouble responding right now. Please try again later."
      )
      broadcast_agent_message(error_message)
    end
  rescue StandardError => e
    set_agent_typing(agent, false)
    Rails.logger.error("AI Agent responder error: #{e.message}\n#{e.backtrace.join("\n")}")
  end

  def build_conversation_history
    @channel.messages
            .top_level
            .includes(:person)
            .order(created_at: :desc)
            .limit(CONVERSATION_HISTORY_LIMIT)
            .reverse
            .map do |msg|
      {
        content: msg.content,
        is_agent: msg.person.is_agent?
      }
    end
  end

  def default_agent_prompt(agent)
    "You are #{agent.name}, a helpful AI assistant. Respond to messages in a friendly and helpful manner."
  end

  def set_agent_typing(agent, is_typing)
    member = @channel.members.find_by(person: agent)
    return unless member

    if is_typing
      member.update(typing_at: Time.current)
    else
      member.update(typing_at: nil)
    end

    # Broadcast typing status
    ChatRoomChannel.broadcast_to(
      @channel,
      {
        type: "typing",
        person_id: agent.id,
        person_name: agent.name,
        is_typing: is_typing
      }
    )
  end

  def broadcast_agent_message(message)
    ChatRoomChannel.broadcast_to(
      @channel,
      {
        type: "message",
        message: ApplicationController.render(
          partial: "messages/message",
          locals: { message: message }
        ),
        sender_id: message.person_id,
        channel_id: @channel.id
      }
    )
  end
end
