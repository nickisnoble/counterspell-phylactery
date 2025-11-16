require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @gm = User.create!(email: "gm@mailertest.com", system_role: "gm", display_name: "GM")
    @player = User.create!(email: "player@mailertest.com", system_role: "player", display_name: "Player")

    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 10.days,
      location: @location,
      status: "upcoming"
    )

    @game = @event.games.create!(gm: @gm, seat_count: 5)

    # Create a seat for the player
    ancestry = Trait.create!(type: "ANCESTRY", name: "Mailer Test Ancestry")
    background = Trait.create!(type: "BACKGROUND", name: "Mailer Test Background")
    class_trait = Trait.create!(type: "CLASS", name: "Mailer Test Class")
    @hero = Hero.create!(
      name: "Mailer Test Hero",
      role: "striker",
      traits: [ancestry, background, class_trait]
    )
    @seat = @game.seats.create!(user: @player, hero: @hero, purchased_at: Time.current)

    @event_email = @event.event_emails.first
  end

  test "reminder" do
    mail = EventMailer.reminder(user: @player, event_email: @event_email)

    assert_equal @event_email.subject, mail.subject
    assert_equal [@player.email], mail.to
    assert_match @event.name, mail.body.encoded
    assert_match @player.display_name, mail.body.encoded
  end
end
