# frozen_string_literal: true

class Conversation < Record
  attr_reader :model, :messages

  def initialize(attributes)
    super
    @model = attributes[:model]
    @messages = Message.where(conversation_id: id)
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
  end

  private

  def attributes
    %w[model]
  end

  def open_ai_client
    @open_ai_client ||= OpenAI::Client.new
  end

  def message_attributes_from_open_ai_client(response)
    response["choices"].first["message"].transform_keys(&:to_sym)
  end
end
