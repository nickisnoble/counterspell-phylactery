require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "requires name" do
    event = Event.new(date: Date.today, location: locations(:one), status: "upcoming")
    assert_not event.valid?
    assert_includes event.errors[:name], "can't be blank"
  end

  test "requires date" do
    event = Event.new(name: "Test Event", location: locations(:one), status: "upcoming")
    assert_not event.valid?
    assert_includes event.errors[:date], "can't be blank"
  end

  test "requires location" do
    event = Event.new(name: "Test Event", date: Date.today, status: "upcoming")
    assert_not event.valid?
    assert_includes event.errors[:location], "must exist"
  end

  test "generates slug from name" do
    event = Event.create!(
      name: "The Grand Tournament",
      date: Date.today,
      location: locations(:one),
      status: "upcoming"
    )
    assert_equal "the-grand-tournament", event.slug
  end

  test "validates name uniqueness case-insensitively" do
    Event.create!(
      name: "Unique Event",
      date: Date.today,
      location: locations(:one),
      status: "upcoming"
    )
    duplicate = Event.new(
      name: "unique event",
      date: Date.today,
      location: locations(:two),
      status: "upcoming"
    )
    assert_not duplicate.valid?
  end

  test "has rich text description field" do
    event = Event.create!(
      name: "Test Event",
      date: Date.today,
      location: locations(:one),
      status: "upcoming"
    )
    assert_respond_to event, :description
    assert event.description.is_a?(ActionText::RichText) || event.description.nil?
  end

  test "allows valid status values" do
    %w[planning upcoming past cancelled].each do |status|
      event = Event.new(
        name: "Test Event #{status}",
        date: Date.today,
        location: locations(:one),
        status: status
      )
      assert event.valid?, "#{status} should be valid"
    end
  end

  test "ticket price defaults to zero" do
    event = Event.create!(
      name: "Free Event",
      date: Date.today,
      location: locations(:one),
      status: "upcoming"
    )
    assert_equal 0, event.ticket_price
  end

  test "automatically creates two reminder broadcasts after create" do
    event = Event.create!(
      name: "Test Event with Broadcasts",
      date: Date.today + 10.days,
      location: locations(:one),
      status: "upcoming"
    )

    assert_equal 2, event.broadcasts.count

    week_before = event.broadcasts.find_by("scheduled_at < ?", event.date - 2.days)
    day_before = event.broadcasts.find_by("scheduled_at > ?", event.date - 2.days)

    assert_not_nil week_before
    assert_not_nil day_before
    assert_match /one week away/, week_before.subject
    assert_match /tomorrow/, day_before.subject
    assert_equal "event_attendees", week_before.recipient_type
    assert_equal "event_attendees", day_before.recipient_type
  end
end
