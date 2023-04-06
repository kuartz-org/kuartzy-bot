# frozen_string_literal: true

require_relative "db/config.rb"

desc "setup application"
task :setup do
  db = SQLite3::Database.new(DB_PATH)

  if db.execute("SELECT sql FROM sqlite_schema").any?
    abort <<~TXT
      Application already setup.
      Run `rake reset` if you want to reset your application, data will be lost!
    TXT
  end

  load_schema(db)
  puts "Application setup successfully!"
end

desc "reset application"
task :reset do
  FileUtils.rm(DB_PATH, force: true)
  db = SQLite3::Database.new(DB_PATH)
  load_schema(db)
  puts "Application reset successfully!"
end

private

def load_schema(db)
  schema_sql_statement = File.read("#{__dir__}/db/schema.sql")
  db.execute_batch schema_sql_statement
end
