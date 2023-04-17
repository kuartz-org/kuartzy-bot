# frozen_string_literal: true

class Conversation < Record
  attr_reader :model, :messages, :topic

  def initialize(attributes)
    super
    @model = attributes[:model]
    @messages = Message.where(conversation_id: id)
    @topic = attributes[:topic]
  end

  def request_assistant_message!
    response = open_ai_client.chat(
      parameters: {
        model: model,
        messages: messages.map(&:to_h)
      }
    )

    messages << Message.create(
      conversation_id: id,
      **message_attributes_from_open_ai_client(response)
    )

    set_topic if topic.to_s.empty?
  end

  private

  def attributes
    %w[model topic]
  end

  def open_ai_client
    @open_ai_client ||= OpenAI::Client.new
  end

  def message_attributes_from_open_ai_client(response)
    response["choices"].first["message"].transform_keys(&:to_sym)
  end

  def set_topic
    response = open_ai_client.chat(
      parameters: {
        model: model,
        messages: messages.map(&:to_h) + [{
          role: "user",
          content: "What is the summary of this conversation in maximum 5 words?"
        }]
      }
    )

    @topic = message_attributes_from_open_ai_client(response)[:content]
    save
  end
end
