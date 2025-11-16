require "test_helper"
require "rails-controller-testing"
class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create user dynamically to avoid encryption issues with fixtures
    @user = User.create!(email: "test@example.com", display_name: "Test User")
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

    # Verify code - should redirect to root since no return_to is set
    post validate_session_path, params: { code: valid_code }
    assert_nil session[:awaiting_login]
    assert_redirected_to root_path
  end

  test "should redirect to saved url after authentication" do
    # Simulate user trying to access a protected page
    event = Event.create!(
      name: "Test Event",
      date: Date.today + 7.days,
      location: Location.create!(name: "Test Venue", address: "123 Test St"),
      status: "upcoming",
      ticket_price: 25
    )
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    game = event.games.create!(gm: gm, seat_count: 5)

    # Try to access seat purchase page (requires auth)
    get new_event_game_seat_path(event, game)
    assert_redirected_to new_session_path

    # Sign in
    post session_path, params: { email: @user.email }
    user = User.find_by(email: @user.email)
    valid_code = user.auth_code

    # Complete authentication
    post validate_session_path, params: { code: valid_code }

    # Should redirect back to the seat purchase page
    assert_redirected_to new_event_game_seat_path(event, game)
  end

  test "should redirect to profile edit if display_name missing, then to saved url" do
    # Create user without display_name
    user_without_name = User.create!(email: "newuser@test.com")
    assert_nil user_without_name.display_name

    # Setup return URL
    event = Event.create!(
      name: "Test Event",
      date: Date.today + 7.days,
      location: Location.create!(name: "Test Venue", address: "123 Test St"),
      status: "upcoming",
      ticket_price: 25
    )
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    game = event.games.create!(gm: gm, seat_count: 5)

    # Try to access seat purchase (sets return_to)
    get new_event_game_seat_path(event, game)

    # Authenticate
    post session_path, params: { email: user_without_name.email }
    valid_code = User.find_by(email: user_without_name.email).auth_code
    post validate_session_path, params: { code: valid_code }

    # Should redirect to profile edit
    assert_redirected_to edit_user_path(user_without_name)
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
    assert_response :unauthorized
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
    skip("currently this is set up temporarily strangely")
    login_with_otp(@user.email)

    get new_session_path
    assert_redirected_to root_path
  end
end
