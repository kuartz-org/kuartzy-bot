# frozen_string_literal: true

require "sqlite3"

DB_PATH = "./db/data.sqlite3"
DB = SQLite3::Database.new DB_PATH
DB.results_as_hash = true
