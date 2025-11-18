require "test_helper"

class BroadcastJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends pending broadcasts" do
    user = User.create!(email: "test@example.com", newsletter: true)
    broadcast = Broadcast.create!(
      subject: "Test Broadcast",
      scheduled_at: 1.hour.ago,
      draft: false,
      recipient_type: "all_subscribers"
    )

    assert_enqueued_emails 1 do
      BroadcastJob.perform_now
    end

    assert broadcast.reload.sent?
  end

  test "does not send draft broadcasts" do
    user = User.create!(email: "test@example.com", newsletter: true)
    broadcast = Broadcast.create!(
      subject: "Draft Broadcast",
      scheduled_at: 1.hour.ago,
      draft: true,
      recipient_type: "all_subscribers"
    )

    assert_no_enqueued_emails do
      BroadcastJob.perform_now
    end

    assert_not broadcast.reload.sent?
  end

  test "does not send future broadcasts" do
    user = User.create!(email: "test@example.com", newsletter: true)
    broadcast = Broadcast.create!(
      subject: "Future Broadcast",
      scheduled_at: 1.hour.from_now,
      draft: false,
      recipient_type: "all_subscribers"
    )

    assert_no_enqueued_emails do
      BroadcastJob.perform_now
    end

    assert_not broadcast.reload.sent?
  end

  test "only sends to users with newsletter preference enabled" do
    subscribed_user = User.create!(email: "subscribed@example.com", newsletter: true)
    unsubscribed_user = User.create!(email: "unsubscribed@example.com", newsletter: false)

    broadcast = Broadcast.create!(
      subject: "Test Broadcast",
      scheduled_at: 1.hour.ago,
      draft: false,
      recipient_type: "all_subscribers"
    )

    assert_enqueued_emails 1 do
      BroadcastJob.perform_now
    end
  end

  test "sends to event attendees" do
    location = Location.create!(name: "Test Venue", address: "123 Test St")
    gm = User.create!(email: "gm@test.com", system_role: "gm", display_name: "GM")
    player = User.create!(email: "player@test.com", system_role: "player", display_name: "Player", newsletter: true)

    event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: location,
      status: "upcoming"
    )

    game = event.games.create!(gm: gm, seat_count: 5)

    ancestry = Trait.create!(type: "ANCESTRY", name: "Test Ancestry #{Time.current.to_i}")
    background = Trait.create!(type: "BACKGROUND", name: "Test Background #{Time.current.to_i}")
    class_trait = Trait.create!(type: "CLASS", name: "Test Class #{Time.current.to_i}")
    hero = Hero.create!(
      name: "Test Hero #{Time.current.to_i}",
      role: "fighter",
      traits: [ancestry, background, class_trait]
    )
    seat = game.seats.create!(user: player, hero: hero, purchased_at: Time.current)

    broadcast = Broadcast.create!(
      subject: "Event Reminder",
      scheduled_at: 1.hour.ago,
      draft: false,
      recipient_type: "event_attendees",
      broadcastable: event
    )

    assert_enqueued_emails 1 do
      BroadcastJob.perform_now
    end

    assert broadcast.reload.sent?
  end
end
