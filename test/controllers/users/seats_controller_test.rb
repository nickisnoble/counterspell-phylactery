require "test_helper"

module Users
  class SeatsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")
      @other_user = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
      @location = Location.create!(name: "Test Venue", address: "123 Test St")
      @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
      @event = Event.create!(
        name: "Test Event",
        date: 7.days.from_now,
        location: @location,
        status: "upcoming"
      )
      @game = @event.games.create!(gm: @gm, seat_count: 5)
      @seat = @game.seats.create!(user: @user)
    end

    test "should get index when authenticated as seat owner" do
      login_with_otp(@user.email)
      get user_seats_path(@user)
      assert_response :success
    end

    test "should redirect index when not authenticated" do
      get user_seats_path(@user)
      assert_redirected_to new_session_path
    end

    test "should redirect index when accessing other user's seats" do
      login_with_otp(@other_user.email)
      get user_seats_path(@user)
      assert_redirected_to root_path
    end

    test "admin can view any user's seats" do
      admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
      login_with_otp(admin.email)
      get user_seats_path(@user)
      assert_response :success
    end

    test "should show seat when authenticated as owner" do
      login_with_otp(@user.email)
      get user_seat_path(@user, @seat)
      assert_response :success
    end
  end
end
