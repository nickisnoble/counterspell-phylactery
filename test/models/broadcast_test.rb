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
end
