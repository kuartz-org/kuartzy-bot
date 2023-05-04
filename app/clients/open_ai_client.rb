# frozen_string_literal: true

class OpenAIClient
  include HTTParty

  base_uri "https://api.openai.com"

  def initialize
    @options = {
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer #{ENV.fetch("OPEN_AI_SECRET_KEY")}"
      }
    }
  end

  def usage
    t = Time.now

    response = self.class.get("/dashboard/billing/usage", @options.merge(query: {
      end_date: Time.new(t.month == 12 ? t.year + 1 : t.year, t.month == 12 ? 1 : t.month + 1, 1) .strftime("%Y-%m-%d"),
      start_date: Time.new(t.year, t.month, 1).strftime("%Y-%m-%d")
    }))

    format("%.2f", (response["total_usage"].to_f / 100))
  end
end
