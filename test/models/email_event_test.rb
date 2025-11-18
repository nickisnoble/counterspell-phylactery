require "test_helper"

class EmailEventTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email: "test@example.com",
      display_name: "Test User",
      system_role: "player"
    )
    @broadcast = Broadcast.create!(
      subject: "Test Broadcast",
      body: "Test body",
      recipient_type: "all_subscribers",
      scheduled_at: 1.day.from_now
    )
  end

  test "valid email event" do
    event = EmailEvent.new(
      user: @user,
      broadcast: @broadcast,
      event_type: "email.delivered",
      resend_email_id: SecureRandom.uuid,
      metadata: { from: "noreply@example.com", to: [@user.email] }
    )
    assert event.valid?
  end

  test "requires user" do
    event = EmailEvent.new(
      event_type: "email.delivered",
      resend_email_id: SecureRandom.uuid
    )
    assert_not event.valid?
    assert_includes event.errors[:user], "must exist"
  end

  test "requires event_type" do
    event = EmailEvent.new(
      user: @user,
      resend_email_id: SecureRandom.uuid
    )
    assert_not event.valid?
    assert_includes event.errors[:event_type], "can't be blank"
  end

  test "requires resend_email_id" do
    event = EmailEvent.new(
      user: @user,
      event_type: "email.delivered"
    )
    assert_not event.valid?
    assert_includes event.errors[:resend_email_id], "can't be blank"
  end

  test "validates event_type inclusion" do
    valid_types = [
      "email.sent",
      "email.delivered",
      "email.delivery_delayed",
      "email.complained",
      "email.bounced",
      "email.opened",
      "email.clicked",
      "email.failed"
    ]

    valid_types.each do |type|
      event = EmailEvent.new(
        user: @user,
        event_type: type,
        resend_email_id: SecureRandom.uuid
      )
      assert event.valid?, "#{type} should be valid"
    end

    event = EmailEvent.new(
      user: @user,
      event_type: "invalid.type",
      resend_email_id: SecureRandom.uuid
    )
    assert_not event.valid?
    assert_includes event.errors[:event_type], "is not included in the list"
  end

  test "broadcast is optional" do
    event = EmailEvent.new(
      user: @user,
      event_type: "email.delivered",
      resend_email_id: SecureRandom.uuid
    )
    assert event.valid?
  end

  test "stores metadata as JSON" do
    metadata = {
      from: "noreply@example.com",
      subject: "Test",
      bounce: { type: "Permanent", message: "Bounced" }
    }

    event = EmailEvent.create!(
      user: @user,
      event_type: "email.bounced",
      resend_email_id: SecureRandom.uuid,
      metadata: metadata
    )

    event.reload
    assert_equal "noreply@example.com", event.metadata["from"]
    assert_equal "Permanent", event.metadata["bounce"]["type"]
  end

  test "scopes by event type" do
    EmailEvent.create!(
      user: @user,
      event_type: "email.delivered",
      resend_email_id: SecureRandom.uuid
    )
    EmailEvent.create!(
      user: @user,
      event_type: "email.bounced",
      resend_email_id: SecureRandom.uuid
    )
    EmailEvent.create!(
      user: @user,
      event_type: "email.delivered",
      resend_email_id: SecureRandom.uuid
    )

    assert_equal 2, EmailEvent.where(event_type: "email.delivered").count
    assert_equal 1, EmailEvent.where(event_type: "email.bounced").count
  end
end
