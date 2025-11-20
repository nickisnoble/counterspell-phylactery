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

  test "show page purchase form provides role selection for selected hero" do
    player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")
    hero = heroes(:one)
    login_with_otp(player.email)

    get event_game_path(@event, @game)
    assert_response :success

    assert_select "form[action='#{event_game_seats_path(@event, @game)}'][data-controller='role-sync']" do
      assert_select "select[name='hero_id'] option[data-role='#{hero.role}'][value='#{hero.id}']"
      assert_select "input[type='hidden'][name='role_selection']"
    end
  end
end
