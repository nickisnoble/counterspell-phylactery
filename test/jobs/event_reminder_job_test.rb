require "test_helper"

class EventReminderJobTest < ActiveJob::TestCase
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 1.day,
      location: @location,
      status: "upcoming"
    )
    # Auto-creates 2 event_emails (1 week before, 1 day before)
    @event_email = @event.event_emails.where("send_at <= ?", Time.current).first
  end

  test "sends pending event emails that are due" do
    # Update send_at to be in the past
    @event_email.update!(send_at: 1.hour.ago)

    assert_nil @event_email.sent_at

    EventReminderJob.perform_now

    assert_not_nil @event_email.reload.sent_at
  end

  test "does not send emails scheduled for the future" do
    @event_email.update!(send_at: 1.day.from_now)

    EventReminderJob.perform_now

    assert_nil @event_email.reload.sent_at
  end

  test "does not resend already sent emails" do
    @event_email.update!(send_at: 1.hour.ago)
    @event_email.mark_as_sent!
    original_sent_at = @event_email.sent_at

    EventReminderJob.perform_now

    # sent_at should not change
    assert_equal original_sent_at.to_i, @event_email.reload.sent_at.to_i
  end
end
