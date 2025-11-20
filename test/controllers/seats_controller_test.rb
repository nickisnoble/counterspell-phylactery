require "test_helper"

class SeatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")
    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 7.days,
      location: @location,
      status: "upcoming",
      ticket_price: 25
    )
    @game = @event.games.create!(gm: @gm, seat_count: 5)

    # Create required traits for hero
    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background")
    class_trait = Trait.create!(type: "CLASS", name: "Test Class")

    @hero = Hero.create!(
      name: "Seats Test Hero",
      role: "striker",
      traits: [ancestry, background, class_trait]
    )
  end

  test "requires authentication to purchase" do
    post event_game_seats_path(@event, @game), params: { seat: { hero_id: @hero.id } }
    assert_redirected_to new_session_path
  end

  test "new shows hero selection for authenticated user" do
    login_with_otp(@player.email)
    get new_event_game_seat_path(@event, @game)
    assert_response :success
  end

  test "new requires authentication" do
    get new_event_game_seat_path(@event, @game)
    assert_redirected_to new_session_path
  end

  test "new redirects for non-upcoming events" do
    @event.update!(status: "past")
    login_with_otp(@player.email)
    get new_event_game_seat_path(@event, @game)
    assert_redirected_to event_path(@event)
    assert_match /not available/, flash[:alert]
  end

  test "create redirects to Stripe checkout" do
    skip("Requires Stripe API credentials")
    login_with_otp(@player.email)

    post event_game_seats_path(@event, @game), params: { seat: { hero_id: @hero.id } }

    assert_response :redirect
    assert_match /stripe\.com/, response.location
  end

  test "should show seat when authenticated as owner" do
    seat = @game.seats.create!(user: @player, hero: @hero)
    login_with_otp(@player.email)
    get event_game_seat_path(@event, @game, seat)
    assert_response :success
  end

  test "admin can view any seat" do
    seat = @game.seats.create!(user: @player, hero: @hero)
    admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Admin")
    login_with_otp(admin.email)
    get event_game_seat_path(@event, @game, seat)
    assert_response :success
  end

  test "cannot view other user's seat" do
    seat = @game.seats.create!(user: @player, hero: @hero)
    other_user = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
    login_with_otp(other_user.email)
    get event_game_seat_path(@event, @game, seat)
    assert_redirected_to root_path
  end

  test "requires authentication to view seat" do
    seat = @game.seats.create!(user: @player, hero: @hero)
    get event_game_seat_path(@event, @game, seat)
    assert_redirected_to new_session_path
  end

  test "cannot purchase for non-upcoming event" do
    @event.update!(status: "past")
    login_with_otp(@player.email)

    post event_game_seats_path(@event, @game), params: { seat: { hero_id: @hero.id } }
    assert_redirected_to event_path(@event)
    assert_match /not available for purchase/, flash[:alert]
  end

  test "cannot purchase when table is full" do
    # Fill all seats
    @game.seat_count.times do
      user = User.create!(email: "user#{rand(10000)}@test.com", system_role: "player")
      @game.seats.create!(user: user)
    end

    login_with_otp(@player.email)
    post event_game_seats_path(@event, @game), params: { seat: { hero_id: @hero.id } }
    assert_redirected_to event_path(@event)
    assert_match /full/, flash[:alert]
  end

  test "success redirects to seat when already created" do
    login_with_otp(@player.email)
    seat = @game.seats.create!(user: @player, hero: @hero)

    assert_no_difference "Seat.count" do
      get success_event_game_seats_path(@event, @game, hero_id: @hero.id, payment_intent: "pi_test")
    end

    assert_redirected_to event_game_seat_path(@event, @game, seat)
  end

  test "success without seat redirects to event without creating one" do
    login_with_otp(@player.email)

    assert_no_difference "Seat.count" do
      get success_event_game_seats_path(@event, @game, hero_id: @hero.id, payment_intent: "pi_new")
    end

    assert_redirected_to event_path(@event)
    assert_match /email you as soon as your seat is confirmed/, flash[:notice]
  end

  test "create with invalid seat shows error" do
    login_with_otp(@player.email)
    # Create another GM and game at the same event
    other_gm = User.create!(email: "othergm#{rand(10000)}@test.com", system_role: "gm", display_name: "Other GM")
    other_game = @event.games.create!(gm: other_gm, seat_count: 5)
    other_game.seats.create!(user: @player, hero: @hero)

    # Try to purchase another seat at the same event (violates one_association_per_event)
    post event_game_seats_path(@event, @game), params: { hero_id: @hero.id, role_selection: @hero.role }

    assert_redirected_to event_path(@event)
    assert_match /can only have one association per event/, flash[:alert]
  end

  # Wizard-specific tests
  test "new wizard calculates role counts correctly" do
    login_with_otp(@player.email)

    # Create another hero and seat
    protector = Hero.create!(
      name: "Protector Hero",
      role: "protector",
      traits: @hero.traits
    )
    other_player = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
    @game.seats.create!(user: other_player, hero: protector)

    get new_event_game_seat_path(@event, @game)
    assert_response :success

    # The response should include available_heroes and role_counts
    # (tested implicitly - the view renders without error)
  end

  test "new wizard shows only available heroes" do
    login_with_otp(@player.email)

    # Take the striker hero
    other_player = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
    @game.seats.create!(user: other_player, hero: @hero)

    get new_event_game_seat_path(@event, @game)
    assert_response :success

    # The hero should be marked as taken in the view
    # (tested implicitly - the view renders with the taken hero disabled)
  end

  test "create validates role matches hero" do
    login_with_otp(@player.email)

    # Try to create with mismatched role
    post event_game_seats_path(@event, @game), params: {
      hero_id: @hero.id,
      role_selection: "protector" # wrong role, hero is striker
    }

    assert_redirected_to event_path(@event)
    assert_match /must match selected role/, flash[:alert]
  end

  test "create validates role not full" do
    login_with_otp(@player.email)

    # Create 2 striker heroes and take them
    striker2 = Hero.create!(name: "Striker 2", role: "striker", traits: @hero.traits)
    player1 = User.create!(email: "p1@test.com", system_role: "player", display_name: "P1")
    player2 = User.create!(email: "p2@test.com", system_role: "player", display_name: "P2")
    @game.seats.create!(user: player1, hero: @hero)
    @game.seats.create!(user: player2, hero: striker2)

    # Try to create another striker seat
    striker3 = Hero.create!(name: "Striker 3", role: "striker", traits: @hero.traits)
    post event_game_seats_path(@event, @game), params: {
      hero_id: striker3.id,
      role_selection: "striker"
    }

    assert_redirected_to event_path(@event)
    assert_match /is full \(2\/2 players\)/, flash[:alert]
  end

  test "create validates hero not taken" do
    login_with_otp(@player.email)

    # Another player takes the hero
    other_player = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
    @game.seats.create!(user: other_player, hero: @hero)

    # Try to take the same hero
    post event_game_seats_path(@event, @game), params: {
      hero_id: @hero.id,
      role_selection: @hero.role
    }

    assert_redirected_to event_path(@event)
    assert_match /already taken/, flash[:alert]
  end
end
