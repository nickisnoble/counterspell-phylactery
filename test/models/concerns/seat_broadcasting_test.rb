require "test_helper"

class SeatBroadcastingTest < ActiveSupport::TestCase
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

    # Create heroes with different roles
    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background")
    class_trait = Trait.create!(type: "CLASS", name: "Test Class")

    @striker = Hero.create!(
      name: "Striker Hero",
      role: "striker",
      traits: [ancestry, background, class_trait]
    )
    @protector = Hero.create!(
      name: "Protector Hero",
      role: "protector",
      traits: [ancestry, background, class_trait]
    )
  end

  test "seat includes SeatBroadcasting concern" do
    assert Seat.included_modules.include?(SeatBroadcasting)
  end

  test "broadcasts when creating seat with user and hero" do
    # This test verifies the broadcast completes without error
    assert_nothing_raised do
      @game.seats.create!(user: @player, hero: @striker)
    end
  end

  test "does not error when creating seat without user" do
    assert_nothing_raised do
      @game.seats.create!(user: nil, hero: nil)
    end
  end

  test "broadcasts when updating seat hero" do
    seat = @game.seats.create!(user: @player, hero: @striker)

    assert_nothing_raised do
      seat.update!(hero: @protector)
    end
  end

  test "broadcasts when checking in seat" do
    seat = @game.seats.create!(user: @player, hero: @striker)

    assert_nothing_raised do
      seat.check_in!
    end
  end

  test "broadcast_wizard_updates with multiple roles" do
    # Create seats with different roles
    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player2")
    seat1 = @game.seats.create!(user: @player, hero: @striker)
    seat2 = @game.seats.create!(user: player2, hero: @protector)

    # Verify broadcast_wizard_updates can be called without error
    assert_nothing_raised do
      seat2.send(:broadcast_wizard_updates)
    end
  end

  test "broadcast_wizard_updates with available heroes" do
    @game.seats.create!(user: @player, hero: @striker)

    # Create another hero that should be available (reuse existing traits)
    charmer = Hero.create!(
      name: "Charmer Hero",
      role: "charmer",
      traits: [@striker.traits.find_by(type: "ANCESTRY"),
               @striker.traits.find_by(type: "BACKGROUND"),
               @striker.traits.find_by(type: "CLASS")]
    )

    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player2")
    seat2 = @game.seats.create!(user: player2, hero: @protector)

    # Should broadcast without error
    assert_nothing_raised do
      seat2.send(:broadcast_wizard_updates)
    end
  end

  test "broadcast_wizard_updates when all heroes taken" do
    # Take all heroes
    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player2")
    @game.seats.create!(user: @player, hero: @striker)
    seat2 = @game.seats.create!(user: player2, hero: @protector)

    # Should still broadcast without error even if no heroes available
    assert_nothing_raised do
      seat2.send(:broadcast_wizard_updates)
    end
  end
end
