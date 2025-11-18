require "httparty"

class ButtondownService
  include HTTParty
  base_uri "https://api.buttondown.email/v1"

  class ConfigurationError < StandardError; end

  def initialize
    @api_key = ENV["BUTTONDOWN_API_KEY"]
  end

  def subscribe(email)
    raise ConfigurationError, "BUTTONDOWN_API_KEY environment variable is not set" unless @api_key

    response = self.class.post(
      "/subscribers",
      headers: headers,
      body: { email: email }.to_json
    )

    # Return true if successful or if already subscribed
    response.success? || response.code == 400
  end

  def unsubscribe(email)
    raise ConfigurationError, "BUTTONDOWN_API_KEY environment variable is not set" unless @api_key

    # First, find the subscriber by email
    subscriber = find_subscriber(email)

    # Return true if subscriber doesn't exist (already unsubscribed)
    return true if subscriber.nil?

    # Unsubscribe by setting subscriber_type to "unactivated"
    response = self.class.patch(
      "/subscribers/#{subscriber["id"]}",
      headers: headers,
      body: { subscriber_type: "unactivated" }.to_json
    )

    response.success?
  end

  private

  def headers
    {
      "Authorization" => "Token #{@api_key}",
      "Content-Type" => "application/json"
    }
  end

  def find_subscriber(email)
    response = self.class.get(
      "/subscribers",
      headers: headers,
      query: { email: email }
    )

    return nil unless response.success?

    results = response.parsed_response["results"]
    results&.first
  end
end
