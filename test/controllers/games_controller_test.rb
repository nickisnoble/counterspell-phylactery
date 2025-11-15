require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM User")
    @event = Event.create!(
      name: "Test Event",
      date: 7.days.from_now,
      location: @location,
      status: "upcoming",
      ticket_price: 25
    )
    @game = @event.games.create!(gm: @gm, seat_count: 5)
  end

  test "should show game for upcoming event" do
    get event_game_path(@event, @game)
    assert_response :success
  end

  test "should redirect for planning event when not authenticated" do
    @event.update!(status: "planning")
    get event_game_path(@event, @game)
    assert_redirected_to events_path
  end

  test "should show game with available seats count" do
    get event_game_path(@event, @game)
    assert_response :success
  end
end
