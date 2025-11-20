require "test_helper"

class EventReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    @player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player")

    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: @location,
      status: "upcoming"
    )

    @game = @event.games.create!(gm: @gm, seat_count: 5)

    # Create a seat for the player
    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry #{Time.current.to_i}")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background #{Time.current.to_i}")
    class_trait = Trait.create!(type: "CLASS", name: "Test Class #{Time.current.to_i}")
    @hero = Hero.create!(
      name: "Test Hero #{Time.current.to_i}",
      role: "striker",
      traits: [ancestry, background, class_trait]
    )
    @seat = @game.seats.create!(user: @player, hero: @hero, purchased_at: Time.current)

    # Auto-creates 2 event_emails (1 week before, 1 day before)
    @event_email = @event.event_emails.first
  end

  test "sends emails to users with seats" do
    # Update send_at to be in the past
    @event_email.update!(send_at: 1.hour.ago)

    assert_enqueued_emails 1 do
      EventReminderJob.perform_now
    end

    assert_not_nil @event_email.reload.sent_at
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
