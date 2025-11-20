require "test_helper"

class Dashboard::SeatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
    @gm1 = User.create!(email: "gm1@test.com", system_role: "gm", display_name: "GM One")
    @gm2 = User.create!(email: "gm2@test.com", system_role: "gm", display_name: "GM Two")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 7.days,
      location: @location,
      status: "upcoming"
    )
    @game1 = @event.games.create!(gm: @gm1, seat_count: 5)
    @game2 = @event.games.create!(gm: @gm2, seat_count: 5)
    @seat = @game1.seats.create!(user: @player)
  end

  test "requires admin" do
    patch dashboard_event_seat_path(@event, @seat), params: { seat: { game_id: @game2.id } }
    assert_redirected_to new_session_path
  end

  test "redirects non-admin" do
    login_with_otp(@player.email)
    patch dashboard_event_seat_path(@event, @seat), params: { seat: { game_id: @game2.id } }
    assert_redirected_to root_path
  end

  test "successfully reassigns seat to different game" do
    login_with_otp(@admin.email)

    assert_equal @game1.id, @seat.game_id

    patch dashboard_event_seat_path(@event, @seat), params: { seat: { game_id: @game2.id } }

    assert_equal @game2.id, @seat.reload.game_id
    assert_response :success
    assert_includes response.body, 'data-controller="seat-reassign"', "seat card should mount seat-reassign Stimulus controller"
  end

  test "returns error when trying to move to full game" do
    login_with_otp(@admin.email)

    # Fill up game2
    5.times do |i|
      user = User.create!(email: "p#{i}@test.com", system_role: "player", display_name: "Player #{i}")
      @game2.seats.create!(user: user)
    end

    patch dashboard_event_seat_path(@event, @seat), params: { seat: { game_id: @game2.id } }

    assert_response :unprocessable_content
    assert_equal @game1.id, @seat.reload.game_id
    assert_includes response.body, "This table is full"
  end
end
