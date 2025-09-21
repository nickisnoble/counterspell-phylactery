require "test_helper"
require "rails-controller-testing"
class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create user dynamically to avoid encryption issues with fixtures
    @user = User.create!(email: "test@example.com")
    # Clear any existing sessions
    @user.sessions.destroy_all
  end

  test "should get new" do
    get new_session_path
    assert_response :success
    assert_select "form[action=?]", session_path
    assert_select "input[name='email']"
  end

  test "should create session request" do
    post session_path, params: { email: @user.email }
    assert_redirected_to verify_session_path
    assert_equal @user.email, session[:awaiting_login]
  end

  test "should reject temporary emails" do
    Nondisposable::DisposableDomain.create!(name: "example.com")
    post session_path, params: { email: "example@example.com" }
    assert_response :unprocessable_content
    assert_nil session[:awaiting_login]
  end

  test "should get verify page" do
    post session_path, params: { email: @user.email }
    get verify_session_path
    assert_response :success
    assert_select "form[action=?]", validate_session_path
    assert_select "input[name='code']"
  end

  test "should validate with correct code" do
    # Setup
    post session_path, params: { email: @user.email }

    # Generate a valid code using the user's method
    user = User.find_by(email: @user.email)
    valid_code = user.auth_code

    # Verify code
    post validate_session_path, params: { code: valid_code }
    assert_nil session[:awaiting_login]
    assert_redirected_to root_path
  end

  test "should reject invalid code" do
    # Setup
    post session_path, params: { email: @user.email }

    # Create an invalid code (we know it's invalid because it's different from user.auth_code)
    user = User.find_by(email: @user.email)
    valid_code = user.auth_code
    invalid_code = valid_code == "000000" ? "111111" : "000000"

    # Use the invalid code
    post validate_session_path, params: { code: invalid_code }
    assert_redirected_to verify_session_path
    assert_equal "Invalid code", flash[:alert]
  end

  test "should destroy session" do
    # Setup: login first using helper method
    login_with_otp(@user.email)

    # Get the user to verify they have an active session
    user = User.find_by(email: @user.email)
    assert_equal 1, user.sessions.count

    # Destroy session
    delete session_path
    assert_redirected_to new_session_path

    # Verify session was destroyed
    assert_equal 0, user.reload.sessions.count
  end

  test "should redirect from login when authenticated" do
    login_with_otp(@user.email)

    get new_session_path
    assert_redirected_to root_path
  end
end
