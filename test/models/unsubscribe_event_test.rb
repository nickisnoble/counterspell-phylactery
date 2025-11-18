require "test_helper"

class UnsubscribeEventTest < ActiveSupport::TestCase
  test "belongs to user" do
    user = User.create!(email: "test@example.com")
    event = UnsubscribeEvent.create!(user: user, reason: "too_many_emails")
    assert_equal user, event.user
  end

  test "validates reason is in allowed list" do
    user = User.create!(email: "test@example.com")
    event = UnsubscribeEvent.new(user: user, reason: "invalid_reason")
    assert_not event.valid?
    assert_includes event.errors[:reason], "is not included in the list"
  end

  test "allows valid reasons" do
    user = User.create!(email: "test@example.com")
    UnsubscribeEvent::REASONS.each do |reason|
      event = UnsubscribeEvent.new(user: user, reason: reason)
      assert event.valid?, "#{reason} should be valid"
    end
  end

  test "allows nil reason" do
    user = User.create!(email: "test@example.com")
    event = UnsubscribeEvent.new(user: user, reason: nil)
    assert event.valid?
  end
end
