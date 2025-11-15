require "test_helper"

class CheckInsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin@checkin.test", system_role: "admin", display_name: "Test Admin")
    @gm = User.create!(email: "gm@checkin.test", system_role: "gm", display_name: "Test GM")
    @player = User.create!(email: "player@checkin.test", system_role: "player", display_name: "Test Player")
    @event = events(:one)
    @game = Game.create!(event: @event, gm: @gm, seat_count: 5)
    @seat = Seat.create!(game: @game, user: @player)
  end

  test "requires authentication to access check-in page" do
    get check_in_path
    assert_redirected_to new_session_path
  end

  test "requires GM or admin role to access check-in page" do
    login_with_otp(@player.email)
    get check_in_path
    assert_redirected_to root_path
  end

  test "allows admin to access check-in page" do
    login_with_otp(@admin.email)
    get check_in_path
    assert_response :success
  end

  test "allows GM to access check-in page" do
    login_with_otp(@gm.email)
    get check_in_path
    assert_response :success
  end

  test "admin can check in a seat via token" do
    login_with_otp(@admin.email)
    assert_not @seat.checked_in?

    post check_in_path, params: { token: @seat.qr_token }
    @seat.reload
    assert @seat.checked_in?
    assert_redirected_to check_in_path
  end

  test "GM can check in a seat via token" do
    login_with_otp(@gm.email)
    assert_not @seat.checked_in?

    post check_in_path, params: { token: @seat.qr_token }
    @seat.reload
    assert @seat.checked_in?
    assert_redirected_to check_in_path
  end

  test "invalid token shows error" do
    login_with_otp(@admin.email)
    post check_in_path, params: { token: "invalid_token" }
    assert_redirected_to check_in_path
    follow_redirect!
    assert_includes response.body, "Invalid QR code"
  end

  test "checking in already checked-in seat shows notice" do
    login_with_otp(@admin.email)
    @seat.check_in!

    post check_in_path, params: { token: @seat.qr_token }
    assert_redirected_to check_in_path
    follow_redirect!
    assert_includes response.body, "already checked in"
  end

  test "admin can manually toggle check-in" do
    login_with_otp(@admin.email)
    assert_not @seat.checked_in?

    patch check_in_seat_path(@seat)
    @seat.reload
    assert @seat.checked_in?

    # Toggle back
    patch check_in_seat_path(@seat)
    @seat.reload
    assert_not @seat.checked_in?
  end

  test "GM can manually check in their own game seats" do
    login_with_otp(@gm.email)
    assert_not @seat.checked_in?

    patch check_in_seat_path(@seat)
    @seat.reload
    assert @seat.checked_in?
  end

  test "GM cannot check in seats for other GMs games" do
    other_gm = User.create!(email: "othergm@checkin.test", system_role: "gm", display_name: "Other GM")
    other_player = User.create!(email: "otherplayer@checkin.test", system_role: "player", display_name: "Other Player")
    other_game = Game.create!(event: @event, gm: other_gm, seat_count: 5)
    other_seat = Seat.create!(game: other_game, user: other_player)

    login_with_otp(@gm.email)
    patch check_in_seat_path(other_seat)

    assert_redirected_to event_path(@event)
    assert_match /permission/i, flash[:alert]
  end
end
