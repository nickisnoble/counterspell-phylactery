require "test_helper"

class SeatPurchaseFormTest < ActiveSupport::TestCase
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

    # Create heroes with traits
    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background")
    char_class = Trait.create!(type: "CLASS", name: "Test Class")

    @striker = Hero.create!(
      name: "Striker Hero",
      role: "striker",
      traits: [ancestry, background, char_class]
    )
    @protector = Hero.create!(
      name: "Protector Hero",
      role: "protector",
      traits: [ancestry, background, char_class]
    )
  end

  test "valid form saves seat" do
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: @player.id,
      hero_id: @striker.id,
      role: "striker"
    )

    assert form.valid?
    assert_difference "Seat.count", 1 do
      assert form.save
    end
  end

  test "requires game_id" do
    form = SeatPurchaseForm.new(
      user_id: @player.id,
      hero_id: @striker.id,
      role: "striker"
    )

    assert_not form.valid?
    assert_includes form.errors[:game_id], "can't be blank"
  end

  test "requires user_id" do
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      hero_id: @striker.id,
      role: "striker"
    )

    assert_not form.valid?
    assert_includes form.errors[:user_id], "can't be blank"
  end

  test "requires hero_id" do
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: @player.id,
      role: "striker"
    )

    assert_not form.valid?
    assert_includes form.errors[:hero_id], "can't be blank"
  end

  test "requires role" do
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: @player.id,
      hero_id: @striker.id
    )

    assert_not form.valid?
    assert_includes form.errors[:role], "can't be blank"
  end

  test "hero must match selected role" do
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: @player.id,
      hero_id: @striker.id,
      role: "protector" # Wrong role!
    )

    assert_not form.valid?
    assert_includes form.errors[:hero], "must match selected role"
  end

  test "rejects role when 2 players already taken" do
    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player 2")
    player3 = User.create!(email: "player3@test.com", system_role: "player", display_name: "Player 3")

    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry 2")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background 2")
    char_class = Trait.create!(type: "CLASS", name: "Test Class 2")

    striker2 = Hero.create!(name: "Striker 2", role: "striker", traits: [ancestry, background, char_class])
    striker3 = Hero.create!(name: "Striker 3", role: "striker", traits: [ancestry, background, char_class])

    # Fill up striker role (2 seats)
    @game.seats.create!(user: @player, hero: @striker)
    @game.seats.create!(user: player2, hero: striker2)

    # Try to add a third striker
    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: player3.id,
      hero_id: striker3.id,
      role: "striker"
    )

    assert_not form.valid?
    assert_includes form.errors[:role], "Striker is full (2/2 players)"
  end

  test "rejects already taken hero" do
    # Another player already has this hero
    @game.seats.create!(user: @player, hero: @striker)

    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player 2")

    form = SeatPurchaseForm.new(
      game_id: @game.id,
      user_id: player2.id,
      hero_id: @striker.id,
      role: "striker"
    )

    assert_not form.valid?
    assert_includes form.errors[:hero], "is already taken at this table"
  end

  test "available_heroes_for_role returns correct heroes" do
    form = SeatPurchaseForm.new(game_id: @game.id)

    strikers = form.available_heroes_for_role("striker")
    assert_includes strikers, @striker
    assert_not_includes strikers, @protector
  end

  test "available_heroes_for_role excludes taken heroes" do
    @game.seats.create!(user: @player, hero: @striker)

    form = SeatPurchaseForm.new(game_id: @game.id)

    strikers = form.available_heroes_for_role("striker")
    assert_not_includes strikers, @striker
  end

  test "role_availability returns correct counts" do
    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player 2")

    @game.seats.create!(user: @player, hero: @striker)
    @game.seats.create!(user: player2, hero: @protector)

    form = SeatPurchaseForm.new(game_id: @game.id)

    assert_equal 1, form.role_availability["striker"]
    assert_equal 1, form.role_availability["protector"]
    assert_equal 0, form.role_availability.fetch("charmer", 0)
  end

  test "role_available? returns true when under 2" do
    form = SeatPurchaseForm.new(game_id: @game.id)

    assert form.role_available?("striker")
    assert form.role_available?("protector")
  end

  test "role_available? returns false when at 2" do
    player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player 2")

    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry 2")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background 2")
    char_class = Trait.create!(type: "CLASS", name: "Test Class 2")

    striker2 = Hero.create!(name: "Striker 2", role: "striker", traits: [ancestry, background, char_class])

    @game.seats.create!(user: @player, hero: @striker)
    @game.seats.create!(user: player2, hero: striker2)

    form = SeatPurchaseForm.new(game_id: @game.id)

    assert_not form.role_available?("striker")
    assert form.role_available?("protector")
  end
end
