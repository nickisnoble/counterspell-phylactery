require "test_helper"

class BroadcastMailerTest < ActionMailer::TestCase
  setup do
    @user = User.create!(email: "test@example.com")
    @broadcast = Broadcast.create!(
      subject: "Test Broadcast",
      scheduled_at: 1.hour.from_now,
      recipient_type: "all_subscribers"
    )
    @broadcast.body = "This is a test broadcast."
  end

  test "broadcast email" do
    email = BroadcastMailer.broadcast(user: @user, broadcast: @broadcast)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_equal "Test Broadcast", email.subject
    assert_match "This is a test broadcast", email.body.encoded
    assert_match "View in browser", email.body.encoded
    assert_match "Unsubscribe", email.body.encoded
  end

  test "event broadcast includes event details" do
    location = Location.create!(name: "Test Venue", address: "123 Test St")
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: location,
      status: "upcoming"
    )

    broadcast = Broadcast.create!(
      subject: "Event Reminder",
      scheduled_at: 1.hour.from_now,
      recipient_type: "event_attendees",
      broadcastable: event
    )

    email = BroadcastMailer.broadcast(user: @user, broadcast: broadcast)

    assert_equal [@user.email], email.to
    assert_equal "Event Reminder", email.subject
    assert_match "Test Event", email.body.encoded
  end

  test "seat confirmation includes QR code and event details" do
    location = Location.create!(name: "Test Venue", address: "123 Test St")
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: location,
      status: "upcoming"
    )
    game = event.games.create!(gm: gm, seat_count: 5)
    seat = game.seats.create!(user: @user, hero: heroes(:one))

    broadcast = Broadcast.create!(
      subject: "Seat Confirmation",
      scheduled_at: Time.current,
      recipient_type: "single_recipient",
      broadcastable: seat
    )

    email = BroadcastMailer.broadcast(user: @user, broadcast: broadcast)

    assert_equal [@user.email], email.to
    assert_equal "Seat Confirmation", email.subject
    assert_match "Test Event", email.body.encoded
    assert_match "svg", email.body.encoded
  end

  test "transactional emails do not show unsubscribe link" do
    location = Location.create!(name: "Test Venue", address: "123 Test St")
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: location,
      status: "upcoming"
    )
    game = event.games.create!(gm: gm, seat_count: 5)
    seat = game.seats.create!(user: @user, hero: heroes(:one))

    broadcast = Broadcast.create!(
      subject: "Seat Confirmation",
      scheduled_at: Time.current,
      recipient_type: "single_recipient",
      broadcastable: seat
    )

    email = BroadcastMailer.broadcast(user: @user, broadcast: broadcast)

    assert broadcast.transactional?
    assert_no_match /Unsubscribe/, email.body.encoded
  end

  test "marketing emails show unsubscribe link" do
    email = BroadcastMailer.broadcast(user: @user, broadcast: @broadcast)

    assert @broadcast.marketing?
    assert_match /Unsubscribe/, email.body.encoded
  end

  test "single_recipient broadcasts only send to seat owner" do
    location = Location.create!(name: "Test Venue", address: "123 Test St")
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    other_player = User.create!(email: "other@test.com", system_role: "player", display_name: "Other")
    event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: location,
      status: "upcoming"
    )
    game = event.games.create!(gm: gm, seat_count: 5)

    # Create second hero for other player
    ancestry2 = Trait.create!(type: "ANCESTRY", name: "Elf #{Time.current.to_i}")
    background2 = Trait.create!(type: "BACKGROUND", name: "Noble #{Time.current.to_i}")
    class2 = Trait.create!(type: "CLASS", name: "Wizard #{Time.current.to_i}")
    hero2 = Hero.create!(name: "Other Hero #{Time.current.to_i}", role: "strategist", traits: [ancestry2, background2, class2])

    seat1 = game.seats.create!(user: @user, hero: heroes(:one))
    seat2 = game.seats.create!(user: other_player, hero: hero2)

    broadcast = Broadcast.create!(
      subject: "Seat Confirmation",
      scheduled_at: Time.current,
      recipient_type: "single_recipient",
      broadcastable: seat1,
      sent_at: nil  # Simulate BroadcastJob picking this up
    )

    # recipients should only return the seat owner, not all event attendees
    assert_equal 1, broadcast.recipients.count
    assert_equal [@user.id], broadcast.recipients.pluck(:id)
  end
end
