# frozen_string_literal: true


require "dotenv/load"
require "sinatra"
require "redcarpet"
require "openai"
require "rouge"
require "rouge/plugins/redcarpet"

require "action_view"
require "action_view/helpers"

require_relative "db/config.rb"

Dir["./app/clients/*_client.rb"].sort.each { |file| require file }
Dir["./app/models/*.rb"].sort.each { |file| require file }
Dir["./app/controllers/*_controller.rb"].sort.each { |file| require file }

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPEN_AI_SECRET_KEY")
  config.organization_id = ENV.fetch("OPEN_AI_ORG_ID")
end

set :views, "#{settings.root}/app/views"

run Sinatra::Application
