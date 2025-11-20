require "test_helper"

class BroadcastTest < ActiveSupport::TestCase
  def setup
    @event = events(:one)
  end

  test "requires subject" do
    broadcast = Broadcast.new(scheduled_at: 1.day.from_now)
    assert_not broadcast.valid?
    assert_includes broadcast.errors[:subject], "can't be blank"
  end

  test "requires scheduled_at" do
    broadcast = Broadcast.new(subject: "Test")
    assert_not broadcast.valid?
    assert_includes broadcast.errors[:scheduled_at], "can't be blank"
  end

  test "has rich text body" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "all_subscribers")
    assert_respond_to broadcast, :body
  end

  test "defaults to draft" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "all_subscribers")
    assert broadcast.draft?
  end

  test "defaults to all_subscribers recipient_type" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now)
    assert_equal "all_subscribers", broadcast.recipient_type
  end

  test "allows event_attendees recipient_type" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "event_attendees", broadcastable: @event)
    assert_equal "event_attendees", broadcast.recipient_type
  end

  test "requires event for event_attendees type" do
    broadcast = Broadcast.new(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "event_attendees")
    assert_not broadcast.valid?
    assert_includes broadcast.errors[:broadcastable], "must exist for event_attendees"
  end

  test "allows updating scheduled_at before sent" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "all_subscribers")
    broadcast.scheduled_at = 2.days.from_now
    assert broadcast.valid?
  end

  test "prevents updating scheduled_at after sent" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago, recipient_type: "all_subscribers")
    broadcast.scheduled_at = 2.days.from_now
    assert_not broadcast.valid?
    assert_includes broadcast.errors[:scheduled_at], "cannot be changed after broadcast is sent"
  end

  test "sent? returns true when sent_at is present" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.ago, sent_at: 1.hour.ago, recipient_type: "all_subscribers")
    assert broadcast.sent?
  end

  test "sent? returns false when sent_at is nil" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "all_subscribers")
    assert_not broadcast.sent?
  end

  test "mark_as_sent! sets sent_at" do
    broadcast = Broadcast.create!(subject: "Test", scheduled_at: 1.day.from_now, recipient_type: "all_subscribers")
    assert_nil broadcast.sent_at
    broadcast.mark_as_sent!
    assert_not_nil broadcast.sent_at
  end

  test "published scope excludes drafts" do
    Broadcast.create!(subject: "Draft", scheduled_at: 1.day.from_now, draft: true, recipient_type: "all_subscribers")
    published = Broadcast.create!(subject: "Published", scheduled_at: 1.day.from_now, draft: false, recipient_type: "all_subscribers")
    assert_equal [published], Broadcast.published.to_a
  end

  test "stores recipient_filters as json" do
    broadcast = Broadcast.create!(
      subject: "Test",
      scheduled_at: 1.day.from_now,
      recipient_type: "filtered",
      recipient_filters: { roles: ["gm", "admin"], attended_event_id: 1 }
    )
    assert_equal ["gm", "admin"], broadcast.recipient_filters["roles"]
    assert_equal 1, broadcast.recipient_filters["attended_event_id"]
  end

  test "recipients excludes users with never_send_email: true" do
    # Create users with different states
    subscribed_user = User.create!(
      email: "subscribed@example.com",
      display_name: "Subscribed",
      system_role: "player",
      newsletter: true,
      never_send_email: false
    )

    bounced_user = User.create!(
      email: "bounced@example.com",
      display_name: "Bounced",
      system_role: "player",
      newsletter: true,
      never_send_email: true
    )

    complained_user = User.create!(
      email: "complained@example.com",
      display_name: "Complained",
      system_role: "player",
      newsletter: true,
      never_send_email: true
    )

    broadcast = Broadcast.create!(
      subject: "Test",
      scheduled_at: 1.day.from_now,
      recipient_type: "all_subscribers"
    )

    recipients = broadcast.recipients
    assert_includes recipients, subscribed_user
    assert_not_includes recipients, bounced_user
    assert_not_includes recipients, complained_user
  end

  test "transactional broadcasts also exclude never_send_email users" do
    location = Location.create!(name: "Test Location", address: "123 Test St")
    event = Event.create!(
      name: "Test Event",
      date: 1.week.from_now,
      location: location,
      status: "upcoming"
    )

    gm = User.create!(
      email: "gm@example.com",
      display_name: "Game Master",
      system_role: "gm"
    )

    active_user = User.create!(
      email: "active@example.com",
      display_name: "Active",
      system_role: "player",
      newsletter: false,
      never_send_email: false
    )

    bounced_user = User.create!(
      email: "bounced@example.com",
      display_name: "Bounced",
      system_role: "player",
      newsletter: false,
      never_send_email: true
    )

    # Create seats for both users
    game = Game.create!(event: event, gm: gm)
    Seat.create!(game: game, user: active_user)
    Seat.create!(game: game, user: bounced_user)

    broadcast = Broadcast.create!(
      subject: "Event Reminder",
      scheduled_at: 1.day.from_now,
      recipient_type: "event_attendees",
      broadcastable: event
    )

    recipients = broadcast.recipients
    assert_includes recipients, active_user
    assert_not_includes recipients, bounced_user, "Transactional emails should also exclude never_send_email users"
  end

  test "filtered recipients include only users who attended any event when attendance_filter is any" do
    location = Location.create!(name: "Loc", address: "123 Road")
    event = Event.create!(name: "Event #{SecureRandom.hex(4)}", slug: "event-#{SecureRandom.hex(4)}", date: 1.week.from_now, location: location, status: "upcoming")
    gm = User.create!(email: "gm@example.com", system_role: "gm")

    attended_user = User.create!(email: "attended@example.com", newsletter: true, system_role: "player")
    never_attended_user = User.create!(email: "never@example.com", newsletter: true, system_role: "player")
    game = Game.create!(event: event, gm: gm)
    Seat.create!(game: game, user: attended_user)

    broadcast = Broadcast.create!(
      subject: "Filtered",
      scheduled_at: 1.day.from_now,
      recipient_type: "filtered",
      recipient_filters: { "attendance_filter" => "any" }
    )

    recipients = broadcast.recipients
    assert_includes recipients, attended_user
    assert_not_includes recipients, never_attended_user
  end

  test "filtered recipients exclude users who attended any event when attendance_filter is never" do
    location = Location.create!(name: "Loc", address: "123 Road")
    event = Event.create!(name: "Event #{SecureRandom.hex(4)}", slug: "event-#{SecureRandom.hex(4)}", date: 1.week.from_now, location: location, status: "upcoming")
    gm = User.create!(email: "gm@example.com", system_role: "gm")

    attended_user = User.create!(email: "attended@example.com", newsletter: true, system_role: "player")
    never_attended_user = User.create!(email: "never@example.com", newsletter: true, system_role: "player")
    game = Game.create!(event: event, gm: gm)
    Seat.create!(game: game, user: attended_user)

    broadcast = Broadcast.create!(
      subject: "Filtered",
      scheduled_at: 1.day.from_now,
      recipient_type: "filtered",
      recipient_filters: { "attendance_filter" => "never" }
    )

    recipients = broadcast.recipients
    assert_includes recipients, never_attended_user
    assert_not_includes recipients, attended_user
  end

  test "filtered recipients include only users who attended specific event" do
    location = Location.create!(name: "Loc", address: "123 Road")
    event_one = Event.create!(name: "Event One #{SecureRandom.hex(4)}", slug: "event-one-#{SecureRandom.hex(4)}", date: 1.week.from_now, location: location, status: "upcoming")
    event_two = Event.create!(name: "Event Two #{SecureRandom.hex(4)}", slug: "event-two-#{SecureRandom.hex(4)}", date: 2.weeks.from_now, location: location, status: "upcoming")
    gm = User.create!(email: "gm@example.com", system_role: "gm")

    user_one = User.create!(email: "one@example.com", newsletter: true, system_role: "player")
    user_two = User.create!(email: "two@example.com", newsletter: true, system_role: "player")
    game_one = Game.create!(event: event_one, gm: gm)
    game_two = Game.create!(event: event_two, gm: gm)
    Seat.create!(game: game_one, user: user_one)
    Seat.create!(game: game_two, user: user_two)

    broadcast = Broadcast.create!(
      subject: "Filtered",
      scheduled_at: 1.day.from_now,
      recipient_type: "filtered",
      recipient_filters: { "attendance_filter" => "specific", "attended_event_id" => event_one.id }
    )

    recipients = broadcast.recipients
    assert_includes recipients, user_one
    assert_not_includes recipients, user_two
  end
end
