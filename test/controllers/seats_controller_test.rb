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
      role: "fighter",
      traits: [ancestry, background, class_trait]
    )
  end

  test "requires authentication to purchase" do
    post event_game_seats_path(@event, @game), params: { seat: { hero_id: @hero.id } }
    assert_redirected_to new_session_path
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

  test "success creates seat and redirects" do
    login_with_otp(@player.email)
    seat = @game.seats.create!(user: @player, hero: @hero)

    get success_event_game_seats_path(@event, @game, hero_id: @hero.id, payment_intent: "pi_test")
    assert_redirected_to event_game_seat_path(@event, @game, seat)
  end
end
