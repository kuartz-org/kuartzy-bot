# frozen_string_literal: true

class MarkdownRender < Redcarpet::Render::HTML
  def initialize(extensions = {})
    super extensions.merge(link_attributes: { target: "_blank" })
  end
  include Rouge::Plugins::Redcarpet
end

class Message < Record
  attr_reader :role, :content, :conversation_id

  def initialize(attributes)
    super
    @role = attributes[:role]
    @content = attributes[:content]
    @conversation_id = attributes[:conversation_id]
  end

  def conversation
    Conversation.find(@conversation_id)
  end

  def to_h
    {
      "role" => role,
      "content" => content
    }
  end

  def content_html
    renderer = MarkdownRender.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true)

    markdown.render(content.gsub("```", "\n```"))
  end

  private

  def attributes
    %w[role content conversation_id]
  end
end
