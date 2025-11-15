require "test_helper"

class EventEmailTest < ActiveSupport::TestCase
  def setup
    @event = events(:one)
  end

  test "requires event" do
    email = EventEmail.new(subject: "Test", send_at: 1.day.from_now)
    assert_not email.valid?
    assert_includes email.errors[:event], "must exist"
  end

  test "requires subject" do
    email = EventEmail.new(event: @event, send_at: 1.day.from_now)
    assert_not email.valid?
    assert_includes email.errors[:subject], "can't be blank"
  end

  test "requires send_at" do
    email = EventEmail.new(event: @event, subject: "Test")
    assert_not email.valid?
    assert_includes email.errors[:send_at], "can't be blank"
  end

  test "has rich text body" do
    email = EventEmail.create!(event: @event, subject: "Test", send_at: 1.day.from_now)
    assert_respond_to email, :body
    assert email.body.is_a?(ActionText::RichText) || email.body.nil?
  end

  test "allows updating send_at before email is sent" do
    email = EventEmail.create!(event: @event, subject: "Test", send_at: 1.day.from_now)
    email.send_at = 2.days.from_now
    assert email.valid?
  end

  test "prevents updating send_at after email is sent" do
    email = EventEmail.create!(
      event: @event,
      subject: "Test",
      send_at: 1.day.ago,
      sent_at: 1.hour.ago
    )
    email.send_at = 2.days.from_now
    assert_not email.valid?
    assert_includes email.errors[:send_at], "cannot be changed after email is sent"
  end

  test "marks email as sent" do
    email = EventEmail.create!(event: @event, subject: "Test", send_at: 1.day.from_now)
    assert_nil email.sent_at
    email.mark_as_sent!
    assert_not_nil email.sent_at
  end

  test "sent? returns true when sent_at is present" do
    email = EventEmail.create!(
      event: @event,
      subject: "Test",
      send_at: 1.day.ago,
      sent_at: 1.hour.ago
    )
    assert email.sent?
  end

  test "sent? returns false when sent_at is nil" do
    email = EventEmail.create!(event: @event, subject: "Test", send_at: 1.day.from_now)
    assert_not email.sent?
  end

  test "prevents updating sent_at after email is sent" do
    email = EventEmail.create!(
      event: @event,
      subject: "Test",
      send_at: 1.day.ago,
      sent_at: 1.hour.ago
    )
    email.sent_at = 2.hours.ago
    assert_not email.valid?
    assert_includes email.errors[:sent_at], "cannot be changed after email is sent"
  end

  test "allows updating body after email is sent" do
    email = EventEmail.create!(
      event: @event,
      subject: "Test",
      send_at: 1.day.ago,
      sent_at: 1.hour.ago
    )
    email.body = "Updated content"
    assert email.valid?
  end
end
