require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "Test GM")
    @admin = User.create!(email: "admin@test.com", system_role: "admin", display_name: "Test Admin")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Test Player")
  end

  test "requires event" do
    game = Game.new(gm: @gm, seat_count: 5)
    assert_not game.valid?
    assert_includes game.errors[:event], "must exist"
  end

  test "requires gm" do
    game = Game.new(event: events(:one), seat_count: 5)
    assert_not game.valid?
    assert_includes game.errors[:gm], "must exist"
  end

  test "seat count defaults to 5" do
    game = Game.create!(event: events(:one), gm: @gm)
    assert_equal 5, game.seat_count
  end

  test "validates gm has gm or admin role" do
    game = Game.new(event: events(:one), gm: @player, seat_count: 5)
    assert_not game.valid?
    assert_includes game.errors[:gm], "must have GM or Admin role"
  end

  test "allows gm role" do
    game = Game.new(event: events(:one), gm: @gm, seat_count: 5)
    assert game.valid?
  end

  test "allows admin role" do
    game = Game.new(event: events(:one), gm: @admin, seat_count: 5)
    assert game.valid?
  end

  test "validates seat count is positive" do
    game = Game.new(event: events(:one), gm: @gm, seat_count: 0)
    assert_not game.valid?
    assert_includes game.errors[:seat_count], "must be greater than 0"
  end

  test "validates GM is unique per event" do
    event = events(:one)
    Game.create!(event: event, gm: @gm, seat_count: 5)
    duplicate_game = Game.new(event: event, gm: @gm, seat_count: 5)
    assert_not duplicate_game.valid?
    assert_includes duplicate_game.errors[:gm], "can only have one association per event"
  end

  test "allows same GM at different events" do
    event1 = events(:one)
    event2 = events(:two)
    Game.create!(event: event1, gm: @gm, seat_count: 5)
    game2 = Game.new(event: event2, gm: @gm, seat_count: 5)
    assert game2.valid?
  end

  test "prevents user from GMing if they have a seat at same event" do
    # Setup: create a game and give the user a seat
    existing_game = Game.create!(event: events(:one), gm: @gm, seat_count: 5)
    player_with_seat = User.create!(email: "player_gm@test.com", system_role: "gm", display_name: "Player GM")
    Seat.create!(game: existing_game, user: player_with_seat)

    # Attempt: try to make that user a GM at the same event
    new_game = Game.new(event: events(:one), gm: player_with_seat, seat_count: 5)
    assert_not new_game.valid?
    assert_includes new_game.errors[:gm], "can only have one association per event"
  end

  test "prevents user from GMing multiple games at same event" do
    # Setup: user is already GMing a game at event one
    Game.create!(event: events(:one), gm: @gm, seat_count: 5)

    # Attempt: try to make them GM another game at the same event
    new_game = Game.new(event: events(:one), gm: @gm, seat_count: 5)
    assert_not new_game.valid?
    assert_includes new_game.errors[:gm], "can only have one association per event"
  end
end
