require "httparty"

class ButtondownService
  include HTTParty
  base_uri "https://api.buttondown.email/v1"
  default_timeout 10

  class ConfigurationError < StandardError; end
  class RateLimitError < StandardError; end
  class AuthenticationError < StandardError; end
  class ServerError < StandardError; end

  def initialize
    @api_key = ENV["BUTTONDOWN_API_KEY"]
  end

  def subscribe(email)
    raise ConfigurationError, "BUTTONDOWN_API_KEY environment variable is not set" unless @api_key

    with_retry do
      response = self.class.post(
        "/subscribers",
        headers: headers,
        body: { email: email }.to_json
      )

      handle_response(response)

      # Return true if successful or if already subscribed (400)
      response.success? || response.code == 400
    end
  end

  def unsubscribe(email, reason: nil)
    raise ConfigurationError, "BUTTONDOWN_API_KEY environment variable is not set" unless @api_key

    with_retry do
      # First, find the subscriber by email
      subscriber = find_subscriber(email)

      # Return true if subscriber doesn't exist (already unsubscribed)
      return true if subscriber.nil?

      # Build the request body
      body = { subscriber_type: "unactivated" }

      # Add unsubscribe reason as a tag if provided
      if reason.present?
        # Buttondown API accepts tags as an array
        # Prepend "unsub:" to reason to identify unsubscribe reasons
        tag = "unsub:#{reason}"
        existing_tags = subscriber["tags"]
        # Ensure existing_tags is an array (handle nil, empty string, etc.)
        existing_tags = [] unless existing_tags.is_a?(Array)
        body[:tags] = (existing_tags + [ tag ]).uniq
      end

      # Unsubscribe by setting subscriber_type to "unactivated"
      response = self.class.patch(
        "/subscribers/#{subscriber["id"]}",
        headers: headers,
        body: body.to_json
      )

      handle_response(response)

      response.success?
    end
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

    # Defensive parsing
    parsed = response.parsed_response
    return nil unless parsed.is_a?(Hash)

    results = parsed["results"]
    return nil unless results.is_a?(Array)

    results.first
  end

  def handle_response(response)
    case response.code
    when 401, 403
      raise AuthenticationError, "Invalid or missing API key"
    when 429
      raise RateLimitError, "Rate limit exceeded"
    when 500..599
      raise ServerError, "Buttondown server error: #{response.code}"
    end
  end

  def with_retry(max_retries: 3, &block)
    retries = 0
    begin
      yield
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED => e
      retries += 1
      if retries < max_retries
        sleep(2**retries) # Exponential backoff
        retry
      end
      raise
    end
  end
end
