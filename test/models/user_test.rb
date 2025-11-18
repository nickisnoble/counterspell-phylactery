require "test_helper"

class UserTest < ActiveSupport::TestCase
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

  test "generates unsubscribe token on create" do
    user = User.create!(email: "test@example.com")
    assert_not_nil user.unsubscribe_token
    assert_equal 32, user.unsubscribe_token.length
  end

  test "unsubscribe tokens are unique" do
    user1 = User.create!(email: "test1@example.com")
    user2 = User.create!(email: "test2@example.com")
    assert_not_equal user1.unsubscribe_token, user2.unsubscribe_token
  end
end
