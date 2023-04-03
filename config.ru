# frozen_string_literal: true

require "dotenv/load"
require "sqlite3"
require "sinatra"
require "redcarpet"
require "openai"
require "rouge"
require "rouge/plugins/redcarpet"

require "./application"

DB_PATH = "./db/data.sqlite3"
DB = SQLite3::Database.new DB_PATH
DB.results_as_hash = true

Dir["./app/models/*.rb"].sort.each { |file| require file }

OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPEN_AI_SECRET_KEY")
  config.organization_id = ENV.fetch("OPEN_AI_ORG_ID")
end

run Sinatra::Application
