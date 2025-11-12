require "test_helper"

class SeatTest < ActiveSupport::TestCase
  def setup
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "Test GM")
    @player1 = User.create!(email: "player1@test.com", system_role: "player", display_name: "Player One")
    @player2 = User.create!(email: "player2@test.com", system_role: "player", display_name: "Player Two")
    @game = Game.create!(event: events(:one), gm: @gm, seat_count: 5)
  end

  test "requires game" do
    seat = Seat.new
    assert_not seat.valid?
    assert_includes seat.errors[:game], "must exist"
  end

  test "allows empty seat without user or hero" do
    seat = Seat.new(game: @game)
    assert seat.valid?
  end

  test "allows seat with user but no hero" do
    seat = Seat.new(game: @game, user: @player1)
    assert seat.valid?
  end

  test "allows seat with user and hero" do
    seat = Seat.new(game: @game, user: @player1, hero: heroes(:one))
    assert seat.valid?
  end

  test "validates hero uniqueness per game" do
    Seat.create!(game: @game, user: @player1, hero: heroes(:one))
    duplicate_seat = Seat.new(game: @game, user: @player2, hero: heroes(:one))
    assert_not duplicate_seat.valid?
    assert_includes duplicate_seat.errors[:hero], "is already taken at this table"
  end

  test "allows same hero at different games" do
    other_game = Game.create!(event: events(:two), gm: @gm, seat_count: 5)
    Seat.create!(game: @game, user: @player1, hero: heroes(:one))
    seat_at_other_game = Seat.new(game: other_game, user: @player2, hero: heroes(:one))
    assert seat_at_other_game.valid?
  end

  test "allows user without hero" do
    seat = Seat.new(game: @game, user: @player1, hero: nil)
    assert seat.valid?
  end
end
