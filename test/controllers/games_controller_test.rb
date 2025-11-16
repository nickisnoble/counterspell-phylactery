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

  test "should show full player details for GMs" do
    suffix = SecureRandom.hex(4)
    ancestry = Trait.create!(name: "Test Ancestry #{suffix}", type: "Ancestry", description: "Test")
    background = Trait.create!(name: "Test Background #{suffix}", type: "Background", description: "Test")
    char_class = Trait.create!(name: "Test Class #{suffix}", type: "Class", description: "Test")

    player = User.create!(email: "player@test.com", system_role: "player", display_name: "Test Player", pronouns: "they/them")
    hero = Hero.new(name: "Test Hero #{suffix}", pronouns: "she/her", role: "fighter")
    hero.traits = [ancestry, background, char_class]
    hero.save!
    @game.seats.create!(user: player, hero: hero)

    login_with_otp(@gm.email)
    get game_path(@game)
    assert_response :success
  end

  test "should show full player details for admins" do
    suffix = SecureRandom.hex(4)
    ancestry = Trait.create!(name: "Admin Test Ancestry #{suffix}", type: "Ancestry", description: "Test")
    background = Trait.create!(name: "Admin Test Background #{suffix}", type: "Background", description: "Test")
    char_class = Trait.create!(name: "Admin Test Class #{suffix}", type: "Class", description: "Test")

    admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
    player = User.create!(email: "player2@test.com", system_role: "player", display_name: "Test Player 2", pronouns: "they/them")
    hero = Hero.new(name: "Admin Test Hero #{suffix}", pronouns: "she/her", role: "fighter")
    hero.traits = [ancestry, background, char_class]
    hero.save!
    @game.seats.create!(user: player, hero: hero)

    login_with_otp(admin.email)
    get game_path(@game)
    assert_response :success
  end

  test "should redirect regular players trying to access game show" do
    player = User.create!(email: "player3@test.com", system_role: "player", display_name: "Test Player 3")
    login_with_otp(player.email)
    get game_path(@game)
    assert_redirected_to events_path
  end

  test "should show checkin button for today's games" do
    @event.update!(date: Date.today)
    player = User.create!(email: "player4@test.com", system_role: "player", display_name: "Test Player 4")
    @game.seats.create!(user: player)

    login_with_otp(@gm.email)
    get game_path(@game)
    assert_response :success
  end
end
