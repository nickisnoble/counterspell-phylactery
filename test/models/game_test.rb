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
end
