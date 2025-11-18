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
      event: event
    )

    email = BroadcastMailer.broadcast(user: @user, broadcast: broadcast)

    assert_equal [@user.email], email.to
    assert_equal "Event Reminder", email.subject
    assert_match "Test Event", email.body.encoded
  end
end
