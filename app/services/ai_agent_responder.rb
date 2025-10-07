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

    # Determine parent message for threading
    parent_message = determine_parent_message

    # Generate and post the AI response
    generate_and_post_response(agent, parent_message)
  end

  private

  def find_agent_in_dm
    @channel.people.agents.first
  end

  def determine_parent_message
    # If this is already a thread reply, use the same parent
    # Otherwise, the message itself becomes the parent for the AI's response
    @message.parent_message_id ? @message.parent_message : @message
  end

  def generate_and_post_response(agent, parent_message)
    # Set typing indicator for the agent
    set_agent_typing(agent, true)

    # Build conversation history
    conversation_history = build_conversation_history(parent_message)

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
      # Create message from agent as a thread reply
      agent_message = @channel.messages.create!(
        person: agent,
        content: result[:content],
        parent_message_id: parent_message.id
      )

      # Broadcast the agent's message
      broadcast_agent_message(agent_message, parent_message)
    else
      Rails.logger.error("AI Agent error: #{result[:error]}")
      # Optionally send an error message
      error_message = @channel.messages.create!(
        person: agent,
        content: "I apologize, but I'm having trouble responding right now. Please try again later.",
        parent_message_id: parent_message.id
      )
      broadcast_agent_message(error_message, parent_message)
    end
  rescue StandardError => e
    set_agent_typing(agent, false)
    Rails.logger.error("AI Agent responder error: #{e.message}\n#{e.backtrace.join("\n")}")
  end

  def build_conversation_history(parent_message)
    # If this is a thread, build history from the thread
    # Include the parent message and all replies in chronological order
    if parent_message
      thread_messages = [parent_message] + parent_message.replies.includes(:person).ordered.to_a

      # Limit to most recent messages if thread is long
      if thread_messages.length > CONVERSATION_HISTORY_LIMIT
        thread_messages = thread_messages.last(CONVERSATION_HISTORY_LIMIT)
      end

      thread_messages.map do |msg|
        {
          content: msg.content,
          is_agent: msg.person.is_agent?
        }
      end
    else
      # Fallback: build from top-level messages (shouldn't happen with new logic)
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
  end

  def default_agent_prompt(agent)
    "You are #{agent.name}, a helpful AI assistant. Respond to messages in a friendly and helpful manner."
  end

  def set_agent_typing(agent, is_typing)
    member = @channel.members.find_by(person: agent)
    return unless member

    if is_typing
      member.typing!
    else
      member.stop_typing!
    end

    payload = {
      type: is_typing ? "typing" : "stop_typing",
      person_id: agent.id,
      person_name: agent.name
    }

    payload[:typing_at] = member.typing_at&.iso8601 if is_typing && member.typing_at

    # Broadcast typing status
    ChatRoomChannel.broadcast_to(@channel, payload)
  end

  def broadcast_agent_message(message, parent_message)
    # Broadcast as thread reply
    ChatRoomChannel.broadcast_to(
      @channel,
      {
        type: "thread_reply",
        parent_message_id: parent_message.id,
        reply: ApplicationController.render(
          partial: "messages/thread_reply",
          locals: { reply: message, current_person: nil }
        ),
        sender_id: message.person_id
      }
    )
  end
end
