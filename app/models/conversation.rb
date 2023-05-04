# frozen_string_literal: true

class Conversation < Record
  attr_reader :model, :messages, :topic, :total_tokens

  def self.models
    available_models = OpenAI::Client.new.models.list["data"].map { |model| model["id"] }

    {
      "GPT-3.5 Turbo" => available_models.include?("gpt-3.5-turbo"),
      "GPT-4" => available_models.include?("gpt-4")
    }
  end

  def initialize(attributes)
    super
    @model = attributes[:model]
    @messages = Message.where(conversation_id: id)
    @topic = attributes[:topic]
    @total_tokens = attributes[:total_tokens] || 0
  end

  def request_assistant_message!
    response = open_ai_client.chat(
      parameters: {
        model: model,
        messages: non_artist_messages.map(&:to_h)
      }
    )

    return error(response) if response.code != 200

    messages << Message.create(
      conversation_id: id,
      **message_attributes_from_open_ai_client(response)
    )

    @total_tokens += token_from_response(response)

    set_topic if topic.to_s.empty?
    save
  end

  def request_image!
    response = open_ai_client.images.generate(
      parameters: {
        prompt: messages.last.content,
        size: "256x256"
      }
    )

    return error(response) if response.code != 200

    image_url = response.dig("data", 0, "url")

    messages << Message.create(
      role: "artist",
      conversation_id: id,
      content: "<img src=\"#{image_url}\" alt=\"#{messages.last.content}\" title=\"#{messages.last.content}\"/>",
    )
  end

  private

  def non_artist_messages
    messages.reject { |message| message.role == "artist" }
  end

  def error(response)
    messages << Message.create(
      role: "system",
      conversation_id: id,
      content: response.body
    )
  end

  def attributes
    %w[model topic total_tokens]
  end

  def open_ai_client
    @open_ai_client ||= OpenAI::Client.new
  end

  def message_attributes_from_open_ai_client(response)
    response["choices"].first["message"].transform_keys(&:to_sym).merge(tokens: token_from_response(response))
  end

  def token_from_response(response)
    response["usage"]["total_tokens"]
  end

  def set_topic
    response = open_ai_client.chat(
      parameters: {
        model: model,
        messages: non_artist_messages.map(&:to_h) + [{
          role: "user",
          content: "What is the summary of this conversation in maximum 5 words?"
        }]
      }
    )

    @topic = message_attributes_from_open_ai_client(response)[:content]
  end
end
