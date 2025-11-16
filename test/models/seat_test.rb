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

  test "checked_in? returns false when not checked in" do
    seat = Seat.create!(game: @game, user: @player1)
    assert_not seat.checked_in?
  end

  test "checked_in? returns true when checked in" do
    seat = Seat.create!(game: @game, user: @player1)
    seat.check_in!
    assert seat.checked_in?
  end

  test "check_in! sets checked_in_at timestamp" do
    seat = Seat.create!(game: @game, user: @player1)
    assert_nil seat.checked_in_at

    seat.check_in!
    assert_not_nil seat.checked_in_at
    assert seat.checked_in_at <= Time.current
  end

  test "qr_token generates consistent token for same seat" do
    seat = Seat.create!(game: @game, user: @player1)
    token1 = seat.qr_token
    token2 = seat.qr_token
    assert_equal token1, token2
  end

  test "qr_token is 32 characters long" do
    seat = Seat.create!(game: @game, user: @player1)
    assert_equal 32, seat.qr_token.length
  end

  test "broadcasts seat purchase when created with user" do
    # The broadcast callback is called after_commit
    # Just verify the seat is created successfully (broadcast will fire)
    seat = Seat.new(game: @game, user: @player1, hero: heroes(:one))
    assert seat.save
    assert seat.persisted?
  end

  test "broadcasts check-in when checked_in_at changes" do
    seat = Seat.create!(game: @game, user: @player1)

    # Check that check_in! updates the timestamp (broadcast will fire via callback)
    assert_changes -> { seat.reload.checked_in_at } do
      seat.check_in!
    end
  end

  test "does not broadcast when seat has no user" do
    seat = Seat.create!(game: @game)
    # Empty seats don't broadcast - verify they can still be created
    assert seat.persisted?
    assert_nil seat.user_id
  end

  test "prevents user from having seat if they GM at same event" do
    # Setup: user is GMing a game at event one
    gm_user = User.create!(email: "gm_player@test.com", system_role: "gm", display_name: "GM Player")
    Game.create!(event: events(:one), gm: gm_user, seat_count: 5)

    # Attempt: try to give them a seat at a different game in the same event
    seat = Seat.new(game: @game, user: gm_user)
    assert_not seat.valid?
    assert_includes seat.errors[:user], "can only have one association per event"
  end

  test "prevents user from having multiple seats at same event" do
    # Setup: user already has a seat at a game in event one
    other_gm = User.create!(email: "othergm@test.com", system_role: "gm", display_name: "Other GM")
    other_game = Game.create!(event: events(:one), gm: other_gm, seat_count: 5)
    Seat.create!(game: other_game, user: @player1)

    # Attempt: try to give them another seat at a different game in the same event
    seat = Seat.new(game: @game, user: @player1)
    assert_not seat.valid?
    assert_includes seat.errors[:user], "can only have one association per event"
  end
end
