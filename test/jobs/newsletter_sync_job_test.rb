require "test_helper"
require "webmock/minitest"

class NewsletterSyncJobTest < ActiveJob::TestCase
  test "job is enqueued" do
    assert_enqueued_with(job: NewsletterSyncJob, args: [ 1, true ]) do
      NewsletterSyncJob.perform_later(1, true)
    end
  end

  test "subscribes user when newsletter is true" do
    user = User.create!(email: "test@example.com", newsletter: false)
    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    stub = stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .with(body: hash_including(email: "test@example.com"))
      .to_return(status: 201, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    NewsletterSyncJob.perform_now(user.id, true)

    assert_requested stub
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "unsubscribes user when newsletter is false" do
    user = User.create!(email: "test@example.com", newsletter: true)
    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    stub_request(:get, "https://api.buttondown.email/v1/subscribers")
      .with(query: hash_including(email: "test@example.com"))
      .to_return(
        status: 200,
        body: { results: [{ id: "test-id", email: "test@example.com" }] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    stub = stub_request(:patch, "https://api.buttondown.email/v1/subscribers/test-id")
      .with(body: hash_including(subscriber_type: "unactivated"))
      .to_return(status: 200, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    NewsletterSyncJob.perform_now(user.id, false)

    assert_requested stub
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "handles missing user gracefully" do
    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    assert_nothing_raised do
      NewsletterSyncJob.perform_now(99999, true)
    end
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "retries on network errors" do
    user = User.create!(email: "test@example.com", newsletter: true)
    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_timeout
      .times(2)
      .then
      .to_return(status: 201, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    assert_nothing_raised do
      NewsletterSyncJob.perform_now(user.id, true)
    end
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end
end
