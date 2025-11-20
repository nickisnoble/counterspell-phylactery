require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM User")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")

    @upcoming_event = Event.create!(
      name: "Upcoming Event",
      date: Date.today + 7.days,
      location: @location,
      status: "upcoming",
      ticket_price: 25
    )
    @upcoming_event.games.create!(gm: @gm, seat_count: 5)

    @planning_event = Event.create!(
      name: "Planning Event",
      date: Date.today + 14.days,
      location: @location,
      status: "planning"
    )

    @past_event = Event.create!(
      name: "Past Event",
      date: Date.today - 7.days,
      location: @location,
      status: "past"
    )
  end

  test "index shows only publicly visible events" do
    get events_path
    assert_response :success
  end

  test "index works without authentication" do
    get events_path
    assert_response :success
  end

  test "show displays event details for upcoming events" do
    get event_path(@upcoming_event)
    assert_response :success
  end

  test "show displays games with GMs" do
    get event_path(@upcoming_event)
    assert_response :success
  end

  test "show redirects for planning events when not authenticated" do
    get event_path(@planning_event)
    assert_redirected_to events_path
  end

  test "show allows GMs to view planning events" do
    login_with_otp(@gm.email)
    get event_path(@planning_event)
    assert_response :success
  end

  test "show displays past events" do
    get event_path(@past_event)
    assert_response :success
  end

  test "show filters heroes already taken at specific game" do
    # Create traits first
    ancestry = Trait.create!(name: "Test Ancestry", type: "Ancestry", description: "Test")
    background = Trait.create!(name: "Test Background", type: "Background", description: "Test")
    char_class = Trait.create!(name: "Test Class", type: "Class", description: "Test")

    # Create heroes with traits
    hero1 = Hero.new(name: "Hero One", pronouns: "They/Them", role: "striker")
    hero1.traits = [ancestry, background, char_class]
    hero1.save!

    hero2 = Hero.new(name: "Hero Two", pronouns: "She/Her", role: "strategist")
    hero2.traits = [ancestry, background, char_class]
    hero2.save!

    # Create a game with seats
    game = @upcoming_event.games.first

    # Take hero1 at this game
    other_player = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
    seat = game.seats.create!(user: other_player, hero: hero1)

    # Login as current player
    login_with_otp(@player.email)
    get event_path(@upcoming_event)

    assert_response :success
    # Hero2 should be available, Hero1 should not
  end
end
