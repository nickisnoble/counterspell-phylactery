require "test_helper"
require "webmock/minitest"

class ButtondownServiceTest < ActiveSupport::TestCase
  setup do
    @email = "test@example.com"
    @api_key = "test_api_key"

    # Stub the API key
    ENV["BUTTONDOWN_API_KEY"] = @api_key
    @service = ButtondownService.new
  end

  teardown do
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "subscribe adds email to buttondown" do
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .with(
        body: { email: @email }.to_json,
        headers: {
          "Authorization" => "Token #{@api_key}",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 201,
        body: { email: @email }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @service.subscribe(@email)
    assert result
  end

  test "subscribe handles existing subscriber gracefully" do
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .with(
        body: { email: @email }.to_json,
        headers: {
          "Authorization" => "Token #{@api_key}",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 400,
        body: { email: ["This email is already subscribed."] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @service.subscribe(@email)
    assert result
  end

  test "unsubscribe removes email from buttondown" do
    subscriber_id = "test-subscriber-id"

    # First stub to get the subscriber
    stub_request(:get, "https://api.buttondown.email/v1/subscribers?email=#{@email}")
      .to_return(
        status: 200,
        body: { results: [{ id: subscriber_id, email: @email }] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # Then stub the unsubscribe
    stub_request(:patch, "https://api.buttondown.email/v1/subscribers/#{subscriber_id}")
      .with(
        body: { subscriber_type: "unactivated" }.to_json,
        headers: {
          "Authorization" => "Token #{@api_key}",
          "Content-Type" => "application/json"
        }
      )
      .to_return(
        status: 200,
        body: { id: subscriber_id, subscriber_type: "unactivated" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @service.unsubscribe(@email)
    assert result
  end

  test "unsubscribe handles non-existent subscriber gracefully" do
    stub_request(:get, "https://api.buttondown.email/v1/subscribers?email=#{@email}")
      .to_return(
        status: 200,
        body: { results: [] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @service.unsubscribe(@email)
    assert result
  end

  test "subscribe raises error when API key is missing" do
    ENV.delete("BUTTONDOWN_API_KEY")
    service = ButtondownService.new

    assert_raises(ButtondownService::ConfigurationError) do
      service.subscribe(@email)
    end
  end

  test "subscribe raises RateLimitError on 429 response" do
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_return(status: 429, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    assert_raises(ButtondownService::RateLimitError) do
      @service.subscribe(@email)
    end
  end

  test "subscribe raises AuthenticationError on 401 response" do
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_return(status: 401, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    assert_raises(ButtondownService::AuthenticationError) do
      @service.subscribe(@email)
    end
  end

  test "subscribe raises ServerError on 500 response" do
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_return(status: 500, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    assert_raises(ButtondownService::ServerError) do
      @service.subscribe(@email)
    end
  end

  test "subscribe retries on timeout" do
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_timeout
      .times(2)
      .then
      .to_return(status: 201, body: { email: @email }.to_json, headers: { "Content-Type" => "application/json" })

    result = @service.subscribe(@email)
    assert result
  end

  test "find_subscriber handles malformed response" do
    stub_request(:get, "https://api.buttondown.email/v1/subscribers?email=#{@email}")
      .to_return(status: 200, body: "not json", headers: {})

    # Should not raise, just return nil
    assert_nothing_raised do
      @service.send(:find_subscriber, @email)
    end
  end
end
