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
      user: @player,
      role: "fighter",
      traits: [ancestry, background, class_trait]
    )
  end

  test "requires authentication to purchase" do
    post game_seats_path(@game), params: { seat: { hero_id: @hero.id } }
    assert_redirected_to new_session_path
  end

  test "create redirects to Stripe checkout" do
    skip("Requires Stripe API credentials")
    login_with_otp(@player.email)

    post game_seats_path(@game), params: { seat: { hero_id: @hero.id } }

    assert_response :redirect
    assert_match /stripe\.com/, response.location
  end
end
