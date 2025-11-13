require "test_helper"

class EventEmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @location = Location.create!(name: "Test Venue", address: "123 Test St")
    @event = Event.create!(
      name: "Test Event",
      date: Date.today + 7.days,
      location: @location,
      status: "upcoming"
    )
    @event_email = @event.event_emails.first # Auto-created by callback
  end

  test "show displays event email content" do
    get event_event_email_path(@event, @event_email)
    assert_response :success
  end

  test "show works without authentication" do
    get event_event_email_path(@event, @event_email)
    assert_response :success
  end
end
