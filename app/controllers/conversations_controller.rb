# frozen_string_literal: true

include ActionView::Helpers::DateHelper

get "/conversations" do
  @conversations = Conversation.all

  @models = Conversation.models

  erb :index
end

post "/conversations" do
  conversation = Conversation.create(model: ENV.fetch("GPT_MODEL"))
  Message.create(
    conversation_id: conversation.id,
    role: "system",
    content: ENV.fetch("SYSTEM_PROMPT")
  )

  redirect "/conversations/#{conversation.id}", 302
end

get "/conversations/:id" do
  @conversations = Conversation.all
  @conversation = Conversation.find(params["id"])

  erb :show
end

post "/conversations/:id/messages" do
  conversation = Conversation.find(params["id"])
  @message = Message.create(
    conversation_id: conversation.id,
    role: "user",
    content: params["content"]
  )
  conversation.messages << @message

  response.headers["Content-Type"] = "text/vnd.turbo-stream.html; charset=utf-8"
  erb :message_stream, layout: false
end

post "/conversations/:id/assistant_message" do
  conversation = Conversation.find(params["id"])
  conversation.request_assistant_message!
  @message = conversation.messages.last

  response.headers["Content-Type"] = "text/vnd.turbo-stream.html; charset=utf-8"
  erb :assistant_answer_stream, layout: false
end
