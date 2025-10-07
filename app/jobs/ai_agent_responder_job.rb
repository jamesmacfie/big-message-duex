class AiAgentResponderJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Message.find_by(id: message_id)
    return unless message

    AiAgentResponder.respond_to_message(message)
  end
end
