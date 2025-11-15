require "test_helper"

class Dashboard::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 7.days,
      location: @location,
      status: "upcoming"
    )
  end

  test "requires admin authentication" do
    get dashboard_events_path
    assert_redirected_to new_session_path
  end

  test "redirects non-admin users" do
    login_with_otp(@player.email)
    get dashboard_events_path
    assert_redirected_to root_path
  end

  test "index displays all events for admins" do
    login_with_otp(@admin.email)
    get dashboard_events_path
    assert_response :success
  end

  test "new displays form for admins" do
    login_with_otp(@admin.email)
    get new_dashboard_event_path
    assert_response :success
  end

  test "create creates event without games" do
    login_with_otp(@admin.email)
    assert_difference("Event.count") do
      post dashboard_events_path, params: {
        event: {
          name: "New Event",
          date: Date.today + 14.days,
          location_id: @location.id,
          status: "planning",
          ticket_price: 10
        }
      }
    end
    assert_redirected_to dashboard_events_path
  end

  test "create creates event with nested games" do
    login_with_otp(@admin.email)
    gm2 = User.create!(email: "gm2@test.com", system_role: "gm", display_name: "GM 2")

    assert_difference("Event.count", 1) do
      assert_difference("Game.count", 2) do
        post dashboard_events_path, params: {
          event: {
            name: "Event with Games",
            date: Date.today + 14.days,
            location_id: @location.id,
            status: "planning",
            games_attributes: {
              "0" => { gm_id: @gm.id, seat_count: 5 },
              "1" => { gm_id: gm2.id, seat_count: 6 }
            }
          }
        }
      end
    end

    event = Event.find_by(name: "Event with Games")
    assert_equal 2, event.games.count
    assert_equal @gm.id, event.games.first.gm_id
    assert_equal 5, event.games.first.seat_count
  end

  test "edit displays form for admins" do
    login_with_otp(@admin.email)
    get edit_dashboard_event_path(@event)
    assert_response :success
  end

  test "update updates event" do
    login_with_otp(@admin.email)
    patch dashboard_event_path(@event), params: { event: { ticket_price: 15.00 } }
    assert_redirected_to dashboard_events_path
    assert_equal 15.00, @event.reload.ticket_price
  end

  test "destroy deletes event and associated games" do
    login_with_otp(@admin.email)
    Game.create!(event: @event, gm: @gm, seat_count: 5)

    assert_difference(["Event.count", "Game.count"], -1) do
      delete dashboard_event_path(@event)
    end
    assert_redirected_to dashboard_events_path
  end

  private

  def sign_in_as(user)
    login_with_otp(user.email)
  end
end
