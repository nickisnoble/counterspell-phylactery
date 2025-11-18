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
    # Now auto-creates broadcasts instead of event_emails
    @broadcast = @event.broadcasts.first
  end

  test "show displays broadcast content via broadcasts controller" do
    get broadcast_path(@broadcast)
    assert_response :success
  end

  test "show works without authentication" do
    get broadcast_path(@broadcast)
    assert_response :success
  end
end
