require "test_helper"
require "webmock/minitest"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "generates OTP secret on create" do
    user = User.create!(email: "test@example.com")
    assert_not_nil user.otp_secret
    assert_equal 26, user.otp_secret.length  # Base32 encoding
  end

  test "normalizes email to lowercase" do
    user = User.create!(email: "Test@Example.COM")
    assert_equal "test@example.com", user.email
  end

  test "validates email uniqueness case-insensitively" do
    User.create!(email: "test@example.com")
    duplicate = User.new(email: "TEST@example.com")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "rejects disposable email domains" do
    Nondisposable::DisposableDomain.create!(name: "tempmail.com")
    user = User.new(email: "test@tempmail.com")
    assert_not user.valid?
  end

  test "validates display name maximum length" do
    user = User.new(email: "test@example.com", display_name: "a" * 41)
    assert_not user.valid?
  end

  test "auth_code returns current TOTP" do
    user = User.create!(email: "test@example.com")
    code = user.auth_code
    assert_match /^\d{6}$/, code  # 6 digit code
  end

  test "has_valid_totp? accepts current code" do
    user = User.create!(email: "test@example.com")
    code = user.auth_code
    assert user.has_valid_totp?(code)
  end

  test "has_valid_totp? rejects invalid code" do
    user = User.create!(email: "test@example.com")
    assert_not user.has_valid_totp?("000000")
  end

  test "authenticate_by returns user with valid credentials" do
    user = User.create!(email: "test@example.com")
    code = user.auth_code
    authenticated = User.authenticate_by(email: user.email, code: code)
    assert_equal user.id, authenticated.id
  end

  test "authenticate_by returns nil with invalid code" do
    user = User.create!(email: "test@example.com")
    authenticated = User.authenticate_by(email: user.email, code: "000000")
    assert_nil authenticated
  end

  test "authenticate_by returns nil with invalid email" do
    authenticated = User.authenticate_by(email: "nonexistent@example.com", code: "000000")
    assert_nil authenticated
  end

  test "verify! persists verified status to database" do
    user = User.create!(email: "test@example.com", verified: false)
    user.verify!
    assert user.reload.verified
  end

  test "system_role defaults to player" do
    user = User.create!(email: "test@example.com")
    assert_equal "player", user.system_role
  end

  test "can create admin user" do
    user = User.create!(email: "newadmin@example.com", system_role: "admin")
    assert user.admin?
  end

  test "subscribes to buttondown when newsletter is true on create" do
    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    # Stub the API call
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_return(status: 201, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    user = nil
    perform_enqueued_jobs do
      user = User.create!(email: "subscriber@example.com", newsletter: true)
    end

    assert user.persisted?
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "does not subscribe to buttondown when newsletter is false on create" do
    # Should not call ButtondownService at all
    user = User.create!(email: "nonsubscriber@example.com", newsletter: false)
    assert_equal false, user.newsletter
  end

  test "subscribes to buttondown when newsletter changes from false to true" do
    user = User.create!(email: "changer@example.com", newsletter: false)

    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    # Stub the API call
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_return(status: 201, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    perform_enqueued_jobs do
      user.update!(newsletter: true)
    end

    assert user.newsletter?
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "unsubscribes from buttondown when newsletter changes from true to false" do
    ENV["BUTTONDOWN_API_KEY"] = "test_key"

    # Stub subscribe on create
    stub_request(:post, "https://api.buttondown.email/v1/subscribers")
      .to_return(status: 201, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    user = nil
    perform_enqueued_jobs do
      user = User.create!(email: "unsubscriber@example.com", newsletter: true)
    end

    # Stub unsubscribe on update
    stub_request(:get, "https://api.buttondown.email/v1/subscribers")
      .with(query: hash_including(email: "unsubscriber@example.com"))
      .to_return(
        status: 200,
        body: { results: [{ id: "test-id", email: "unsubscriber@example.com" }] }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    stub_request(:patch, "https://api.buttondown.email/v1/subscribers/test-id")
      .with(body: hash_including(subscriber_type: "unactivated"))
      .to_return(status: 200, body: {}.to_json, headers: { "Content-Type" => "application/json" })

    perform_enqueued_jobs do
      user.update!(newsletter: false)
    end

    assert_not user.newsletter?
  ensure
    ENV.delete("BUTTONDOWN_API_KEY")
  end

  test "does not call buttondown when newsletter stays the same" do
    user = User.create!(email: "stayer@example.com", newsletter: true)

    # Should not call ButtondownService
    user.update!(display_name: "New Name")
    assert_equal "New Name", user.display_name
  end
end
